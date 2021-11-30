import Foundation

public struct RanasaReplacer {
    var run: (Path, Path, Path, Bool, Log?) throws -> Void
    
    public func callAsFunction(
        at input: Path,
        backup storeBase: Path,
        root: Path,
        isSimulator: Bool,
        verbose: Log? = nil
    ) throws {
        try run(input, storeBase, root, isSimulator, verbose)
    }
}

public extension RanasaReplacer {
    static func live(
        decodeSetting: DecodeSettings = .live(),
        replacer: BinaryReplace = .live()
    ) -> Self {
        .init { (input: Path, storeBase: Path, root: Path, isSimulator: Bool, log: Log?) in
            try decodeSetting(input: input, srcroot: root, log).forEach { (setting: FileStructure) in
                let libraryName = setting.path.lastComponent
                let storePath = storeBase.addingComponent(libraryName)
                if isSimulator {
                    try replacer(
                        setting: setting,
                        input: storePath.treePath(.arm64_simulator).addingComponent(libraryName),
                        log?.indented())
                } else {
                    try replacer(
                        setting: setting,
                        input: storePath.treePath(.arm64).addingComponent(libraryName),
                        log?.indented())
                }
            }
        }
    }
}
