// https://github.com/bogo/arm64-to-sim/blob/main/LICENSE
//
// MIT License
//
// Copyright (c) 2021 Bogo Giertler
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// Modify arasan01 2021

import Foundation
import MachO

public enum TransmogrifierError: Error {
    case fileNotFound(String)
    case noCorrectBinary(String)
    case alreadyProcessed
    case noSupportedFormat(String)
    case unknown
}

// support checking for Mach-O `cmd` and `cmdsize` properties
extension Data {
    var loadCommand: UInt32 {
        let lc: load_command = withUnsafeBytes { $0.load(as: load_command.self) }
        return lc.cmd
    }
    
    var commandSize: Int {
        let lc: load_command = withUnsafeBytes { $0.load(as: load_command.self) }
        return Int(lc.cmdsize)
    }
    
    func asStruct<T>(fromByteOffset offset: Int = 0) -> T {
        return withUnsafeBytes { $0.load(fromByteOffset: offset, as: T.self) }
    }
}

extension Array where Element == Data {
    func merge() -> Data {
        return reduce(into: Data()) { $0.append($1) }
    }
}

// support peeking at Data contents
extension FileHandle {
    func peek(upToCount count: Int) throws -> Data? {
        // persist the current offset, since `upToCount` doesn't guarantee all bytes will be read
        let originalOffset = offsetInFile
        let data = try read(upToCount: count)
        try seek(toOffset: originalOffset)
        return data
    }
}

public enum Transmogrifier {
    private static func readBinary(atPath path: String, isDynamic: Bool = false) throws -> (Data, [Data], Data) {
        guard let handle = FileHandle(forReadingAtPath: path) else {
            throw TransmogrifierError.fileNotFound("Cannot open a handle for the file at \(path). Aborting.")
        }
        
        // chop up the file into a relevant number of segments
        let headerData = try! handle.read(upToCount: MemoryLayout<mach_header_64>.stride)!
        
        let header: mach_header_64 = headerData.asStruct()
        if header.magic != MH_MAGIC_64 || header.cputype != CPU_TYPE_ARM64 {
            throw TransmogrifierError.noCorrectBinary("The file is not a correct arm64 binary. Try thinning (via lipo) or unarchiving (via ar) first.")
        }
        
        let loadCommandsData: [Data] = (0..<header.ncmds).map { _ in
            let loadCommandPeekData = try! handle.peek(upToCount: MemoryLayout<load_command>.stride)
            return try! handle.read(upToCount: Int(loadCommandPeekData!.commandSize))!
        }
        
        if isDynamic {
            let bytesToDiscard = abs(MemoryLayout<build_version_command>.stride - MemoryLayout<version_min_command>.stride)
            _ = handle.readData(ofLength: bytesToDiscard)
        }
        
        let programData = try! handle.readToEnd()!
        
        try! handle.close()
        
        return (headerData, loadCommandsData, programData)
    }
    
    private static func updateSegment64(_ data: Data, _ offset: UInt32) -> Data {
        // decode both the segment_command_64 and the subsequent section_64s
        var segment: segment_command_64 = data.asStruct()
        
        let sections: [section_64] = (0..<Int(segment.nsects)).map { index in
            let offset = MemoryLayout<segment_command_64>.stride + index * MemoryLayout<section_64>.stride
            return data.asStruct(fromByteOffset: offset)
        }
        
        // shift segment information by the offset
        segment.fileoff += UInt64(offset)
        segment.filesize += UInt64(offset)
        segment.vmsize += UInt64(offset)
        
        let offsetSections = sections.map { section -> section_64 in
            let sectionType = section.flags & UInt32(SECTION_TYPE)
            switch Int32(sectionType) {
            case S_ZEROFILL, S_GB_ZEROFILL, S_THREAD_LOCAL_ZEROFILL:
                return section
            case _: break
            }
            
            var section = section
            section.offset += UInt32(offset)
            section.reloff += section.reloff > 0 ? UInt32(offset) : 0
            return section
        }
        
        var datas = [Data]()
        datas.append(Data(bytes: &segment, count: MemoryLayout<segment_command_64>.stride))
        datas.append(contentsOf: offsetSections.map { section in
            var section = section
            return Data(bytes: &section, count: MemoryLayout<section_64>.stride)
        })
        
        return datas.merge()
    }
    
    private static func updateVersionMin(_ data: Data, _ offset: UInt32, minos: UInt32, sdk: UInt32) -> Data {
        var command = build_version_command(cmd: UInt32(LC_BUILD_VERSION),
                                            cmdsize: UInt32(MemoryLayout<build_version_command>.stride),
                                            platform: UInt32(PLATFORM_IOSSIMULATOR),
                                            minos: minos << 16 | 0 << 8 | 0,
                                            sdk: sdk << 16 | 0 << 8 | 0,
                                            ntools: 0)
        
        return Data(bytes: &command, count: MemoryLayout<build_version_command>.stride)
    }
    
    private static func updateDataInCode(_ data: Data, _ offset: UInt32) -> Data {
        var command: linkedit_data_command = data.asStruct()
        command.dataoff += offset
        return Data(bytes: &command, count: data.commandSize)
    }
    
    private static func updateSymTab(_ data: Data, _ offset: UInt32) -> Data {
        var command: symtab_command = data.asStruct()
        command.stroff += offset
        command.symoff += offset
        return Data(bytes: &command, count: data.commandSize)
    }
    
    private static func computeLoadCommandsEditor(_ loadCommandsData: [Data], isDynamic: Bool) throws -> ((Data, UInt32, UInt32) throws -> Data) {
        
        if isDynamic {
            return updateDylibFile
        }
        
        var contains_LC_VERSION_MIN_IPHONEOS = false
        var contains_LC_BUILD_VERSION = false
        for lc in loadCommandsData {
            let loadCommand = UInt32(lc.loadCommand)
            if loadCommand == LC_VERSION_MIN_IPHONEOS {
                contains_LC_VERSION_MIN_IPHONEOS = true
            } else if loadCommand == LC_BUILD_VERSION {
                contains_LC_BUILD_VERSION = true
            }
        }
        
        if contains_LC_VERSION_MIN_IPHONEOS == contains_LC_BUILD_VERSION {
            if contains_LC_BUILD_VERSION == true {
                throw TransmogrifierError.noSupportedFormat("Bad Mach-O Object file: Both LC_VERSION_MIN_IPHONEOS and LC_BUILD_VERSION are present.\nEither one of them should be present")
            } else {
                throw TransmogrifierError.noSupportedFormat("Bad Mach-O Object file: does not contain LC_VERSION_MIN_IPHONEOS or LC_BUILD_VERSION.\nEither one of them should be present")
            }
        }
        
        if contains_LC_VERSION_MIN_IPHONEOS {
            // `offset` is kind of a magic number here, since we know that's the only meaningful change to binary size
            // having a dynamic `offset` requires two passes over the load commands and is left as an exercise to the reader
            return updatePreiOS12ObjectFile
        } else {
            return updatePostiOS12ObjectFile
        }
    }
    
    
    static func updatePostiOS12ObjectFile(lc: Data, minos: UInt32, sdk: UInt32) -> Data {
        let cmd = Int32(bitPattern: lc.loadCommand)
        switch cmd {
        case LC_BUILD_VERSION:
            return updateVersionMin(lc, 0, minos: minos, sdk: sdk)
        default:
            return lc
        }
    }
    
    static func updatePreiOS12ObjectFile(lc: Data, minos: UInt32, sdk: UInt32) -> Data {
        // `offset` is kind of a magic number here, since we know that's the only meaningful change to binary size
        // having a dynamic `offset` requires two passes over the load commands and is left as an exercise to the reader
        let offset = UInt32(abs(MemoryLayout<build_version_command>.stride - MemoryLayout<version_min_command>.stride))
        let cmd = Int32(bitPattern: lc.loadCommand)
        switch  cmd {
        case LC_SEGMENT_64:
            return updateSegment64(lc, offset)
        case LC_VERSION_MIN_IPHONEOS:
            return updateVersionMin(lc, offset, minos: minos, sdk: sdk)
        case LC_DATA_IN_CODE, LC_LINKER_OPTIMIZATION_HINT:
            return updateDataInCode(lc, offset)
        case LC_SYMTAB:
            return updateSymTab(lc, offset)
        case LC_BUILD_VERSION:
            return updateVersionMin(lc, offset, minos: minos, sdk: sdk)
        default:
            return lc
        }
    }
    
    static func updateDylibFile(lc: Data, minos: UInt32, sdk: UInt32) throws -> Data {
        // `offset` is kind of a magic number here, since we know that's the only meaningful change to binary size
        // having a dynamic `offset` requires two passes over the load commands and is left as an exercise to the reader
        let offset = UInt32(abs(MemoryLayout<build_version_command>.stride - MemoryLayout<version_min_command>.stride))
        let cmd = Int32(bitPattern: lc.loadCommand)
        guard cmd != LC_BUILD_VERSION else {
            throw TransmogrifierError.alreadyProcessed
        }
        if cmd == LC_VERSION_MIN_IPHONEOS {
            return updateVersionMin(lc, offset, minos: minos, sdk: sdk)
        }
        return lc
    }
    
    
    public static func processBinary(atPath path: String, minos: UInt32 = 13, sdk: UInt32 = 13, isDynamic: Bool = false) throws {
        let (headerData, loadCommandsData, programData) = try readBinary(atPath: path, isDynamic: isDynamic)
        
        let editor = try computeLoadCommandsEditor(loadCommandsData, isDynamic: isDynamic)
        
        let editedCommandsData = try loadCommandsData
            .map { return try editor($0, minos, sdk) }
            .merge()
        
        var header: mach_header_64 = headerData.asStruct()
        header.sizeofcmds = UInt32(editedCommandsData.count)
        
        // reassemble the binary
        let reworkedData = [
            Data(bytes: &header, count: MemoryLayout<mach_header_64>.stride),
            editedCommandsData,
            programData
        ].merge()
        
        // save back to disk
        try reworkedData.write(to: URL(fileURLWithPath: path))
    }
}
