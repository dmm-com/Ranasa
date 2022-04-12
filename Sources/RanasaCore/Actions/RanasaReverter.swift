import Foundation

public struct RanasaReverter {
    var run: (Path, Path, Path, Log?) throws -> Void
    
    public func callAsFunction(
        at input: Path,
        backup storeBase: Path,
        root: Path,
        verbose: Log? = nil
    ) throws {
        try run(input, storeBase, root, verbose)
    }
}

public extension RanasaReverter {
    static func live(
        decodeSetting: DecodeSettings = .live(),
        replacer: BinaryReplace = .live(),
        fileManager: FileManager = .default
    ) -> Self {
        .init { (input: Path, storeBase: Path, root: Path, log: Log?) in
            try decodeSetting(input: input, srcroot: root, log).forEach { (setting: FileStructure) in
                log?(.normal, "[Revert binary]")
                let libraryName = setting.path.lastComponent
                let storePath = storeBase.addingComponent(libraryName)
                let originalPath = storePath.addingTreePath(.original).addingComponent(libraryName)
                
                if fileManager.fileExists(atPath: originalPath.string) {
                    try replacer(
                        setting: setting,
                        input: originalPath,
                        log?.indented())
                } else {
                    log?(.normal, "Not found original binary")
                }
            }
        }
    }
}
