import XCTest
@testable import RanasaCore

/// This is not test, this is print-debug code, いえぇあ
final class RanasaCoreTests: XCTestCase {
    
    enum Action: Equatable {
        case didDep([String])
        case didLog(LogLevel, String)
        
        var mean: [String] {
            switch self {
            case .didDep(let strings):
                return strings
            case .didLog(_, let string):
                return ["Log", string]
            }
        }
    }
    
    override func setUp() {
        didEffects.removeAll()
    }
    
    var didEffects = [Action]()
    var didDirs = Set<String>()
    
    func testCore() throws {
        let log: Log = .init { level, message in
            self.didEffects.append(.didLog(level, message))
        }
        
        let core: RanasaCore = .live(
            createDir: .init(run: { path, _ in
                self.didEffects.append(.didDep([
                    "Reach - createDir",
                    "output: \(path.string)"
                ]))
                self.didDirs.insert(path.string)
            }),
            decodeSetting: .init(run: { path, srcroot, _ in
                self.didEffects.append(.didDep([
                    "Reach - decodeSetting",
                    "input: \(path.string)"
                ]))
                self.didDirs.insert(path.string)
                return [
                    FileStructure(path: Path("\(srcroot.string)/path/to/👿/binary1"), linking: .static),
                    FileStructure(path: Path("\(srcroot.string)/path/to/🙊/binary2"), linking: .dynamic)
                ]
            }),
            staticAction: .init(run: { path, libName, minos, sdk, _ in
                self.didEffects.append(.didDep([
                    "Reach - staticAction",
                    "input: \(path.string)",
                    "libName: \(libName)",
                    "minos : \(minos), sdk : \(sdk)"
                ]))
                self.didDirs.insert(path.string)
            }),
            dynamicAction: .init(run: { path, libName, minos, sdk, _ in
                self.didEffects.append(.didDep([
                    "Reach - dynamicAction",
                    "input: \(path.string)",
                    "libName: \(libName)",
                    "minos : \(minos), sdk : \(sdk)"
                ]))
                self.didDirs.insert(path.string)
            }),
            getArchs: .init(run: { path, _ in
                self.didEffects.append(.didDep([
                    "---------- Maybe Start Position ----------",
                    "Reach - getArchs",
                    "input: \(path.string)"
                ]))
                self.didDirs.insert(path.string)
                return [.arm64, .x86_64]
            }),
            lipoThin: .init(run: { input, arch, output, _ in
                self.didEffects.append(.didDep([
                    "Reach - lipoThin",
                    "input: \(input.string)",
                    "output: \(output.string)",
                    "arch: \(arch.rawValue)"
                ]))
                self.didDirs.insert(input.string)
                self.didDirs.insert(output.string)
            }),
            lipoCreate: .init(run: { paths, output, _ in
                self.didEffects.append(.didDep([
                    "Reach - lipoCreate",
                    "inputs: \(paths.map(\.string).joined(separator: ", "))",
                    "output: \(output.string)"
                ]))
                paths.forEach { self.didDirs.insert($0.string) }
                self.didDirs.insert(output.string)
            }),
            lipoExtract: .init(run: { input, archs, output, _ in
                self.didEffects.append(.didDep([
                    "Reach - lipoExtract",
                    "input: \(input.string)",
                    "archs: \(archs.map(\.rawValue).joined(separator: ", "))",
                    "output: \(output.string)"
                ]))
                self.didDirs.insert(input.string)
                self.didDirs.insert(output.string)
            }),
            copyItem: .init(run: { input, output, _ in
                self.didEffects.append(.didDep([
                    "Reach - copyItem",
                    "input: \(input.string)",
                    "output: \(output.string)"
                ]))
                self.didDirs.insert(input.string)
                self.didDirs.insert(output.string)
            }),
            deleteItem: .init(run: { path, _ in
                self.didEffects.append(.didDep([
                    "Reach - deleteItem",
                    "input: \(path.string)"
                ]))
                self.didDirs.insert(path.string)
            }),
            fileManager: .default)
        try core(
            at: Path("/path/to/👺/input"),
            backup: Path("/path/to/🤖/backup"),
            root: Path("/Root"),
            minos: 13,
            sdk: 13,
            verbose: log
        )
        
        print("--------- LOG START -----------")
        didEffects.forEach {
            switch $0 {
            case .didLog(let level, let str):
                print("didLog")
                print("\tlevel: \(level), message: \(str)")
            case .didDep(let strs):
                print("didDep")
                strs.forEach({ print("\t\($0)") })
            }
        }
        print("--------- LOG Dirs -----------")
        didDirs.sorted().forEach {
            print($0)
        }
        print("--------- LOG END -----------")
    }
}
