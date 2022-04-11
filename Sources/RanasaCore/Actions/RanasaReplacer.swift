import Foundation

public struct RanasaReplacer {
    var run: (Path, Path, Path, Bool, Bool, Log?) throws -> Void
    
    public func callAsFunction(
        at input: Path,
        backup storeBase: Path,
        root: Path,
        isThin: Bool,
        isSimulator: Bool,
        verbose: Log? = nil
    ) throws {
        try run(input, storeBase, root, isThin, isSimulator, verbose)
    }
}

public extension RanasaReplacer {
    static func live(
        decodeSetting: DecodeSettings = .live(),
        replacer: BinaryReplace = .live()
    ) -> Self {
        .init { (input: Path, storeBase: Path, root: Path, isThin: Bool, isSimulator: Bool, log: Log?) in
            try decodeSetting(input: input, srcroot: root, log).forEach { (setting: FileStructure) in
                let libraryName = setting.path.lastComponent
                let storePath = storeBase.addingComponent(libraryName)
                var path: Path {
                    switch (isSimulator, isThin) {
                    case (true, true):
                        return storePath.addingTreePath(.arm64_simulator).addingComponent(libraryName)
                    case (true, false):
                        return storePath.addingTreePath(.fat_simulator).addingComponent(libraryName)
                    case (false, _):
                        return storePath.addingTreePath(.arm64).addingComponent(libraryName)
                    }
                }
                try replacer(
                    setting: setting,
                    input: path,
                    log?.indented())
            }
        }
    }
}
