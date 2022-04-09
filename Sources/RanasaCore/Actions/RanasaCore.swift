import Foundation

public enum RanasaCoreError: Error {
    case arm64NotFound
}

public struct RanasaCore {
    var run: (Path, Path, Path, Float?, Float?, Log?) throws -> Void

    public func callAsFunction(
        at input: Path,
        backup storeBase: Path,
        root: Path,
        minos: Float?,
        sdk: Float?,
        verbose: Log? = nil
    ) throws {
        try run(input, storeBase, root, minos, sdk, verbose)
    }
}

public extension RanasaCore {
    static func live(
        createDir: CreateDir = .live(),
        decodeSetting: DecodeSettings = .live(),
        staticAction: StaticAction = .live(),
        dynamicAction: DynamicAction = .live(),
        getArchs: GetArchs = .live(),
        lipoThin: LipoThin = .live(),
        lipoCreate: LipoCreate = .live(),
        lipoExtract: LipoExtract = .live(),
        copyItem: CopyItem = .live(),
        deleteItem: DeleteItem = .live(),
        fileManager: FileManager = .default
    ) -> Self {
        .init { (input: Path, storeBase: Path, root: Path, minos: Float?, sdk: Float?, log: Log?) in
            try decodeSetting(input: input, srcroot: root, log).forEach { (setting: FileStructure) in
                
                let libraryName = setting.path.lastComponent
                let storePath = storeBase.addingComponent(libraryName)
                
                // If already rewrited, skip
                if fileManager.fileExists(atPath: storePath.treePath(.arm64).addingComponent(libraryName).string) &&
                    fileManager.fileExists(atPath: storePath.treePath(.arm64_simulator).addingComponent(libraryName).string) {
                    log?(.normal, "skip \(libraryName)")
                    return
                }
                
                // Detect including arm64 binary
                let _archs = try getArchs(binaryPath: setting.path, log?.indented())
                guard _archs.contains(.arm64) else { throw RanasaCoreError.arm64NotFound }
                let archs = _archs.filter { $0 != .arm64 }
                
                // Creating directory tree
                try WorkingTree.allCases.forEach { leaf in
                    let workPath = storePath.treePath(leaf)
                    guard !fileManager.dirExists(atPath: workPath.string) else { return }
                    try createDir(input: workPath, log?.indented())
                }
                
                // Reserve the working directory for recursive deletion.
                defer {
                    try? deleteItem(
                        input: storePath.treePath(.working),
                        log?.indented())
                }
                
                let originalBinary = storePath.treePath(.original).addingComponent(libraryName)
                if !fileManager.fileExists(atPath: originalBinary.string) {
                    try copyItem(current: setting.path, destination: originalBinary, log?.indented())
                }
                
                // Only arm64 format
                if archs.isEmpty {
                    try copyItem(
                        current: setting.path,
                        destination: storePath.treePath(.thin).addingComponent(libraryName),
                        log?.indented())
                } else {
                    try lipoThin(
                        input: setting.path,
                        arch: .arm64,
                        output: storePath.treePath(.thin).addingComponent(libraryName),
                        log?.indented())
                }
                
                try copyItem(
                    current: storePath.treePath(.thin).addingComponent(libraryName),
                    destination: storePath.treePath(.arm64).addingComponent(libraryName),
                    log?.indented())
                switch setting.linking {
                case .static:
                    try staticAction(
                        current: storePath.treePath(.thin),
                        libName: libraryName,
                        minos: minos,
                        sdk: sdk,
                        log?.indented())
                case .dynamic:
                    try dynamicAction(
                        current: storePath.treePath(.thin),
                        libName: libraryName,
                        minos: minos,
                        sdk: sdk,
                        log?.indented())
                }
                try copyItem(
                    current: storePath.treePath(.thin).addingComponent(libraryName),
                    destination: storePath.treePath(.arm64_simulator).addingComponent(libraryName),
                    log?.indented())
            }
        }
    }
}
