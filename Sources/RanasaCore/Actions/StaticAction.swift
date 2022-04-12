import Foundation
public struct StaticAction {
    var run: (Path, String, Float?, Float?, Log?) throws -> Void
    
    public func callAsFunction(current: Path, libName: String, minos: Float?, sdk: Float?, _ log: Log? = nil) throws {
        try run(current, libName, minos, sdk, log)
    }
}

public extension StaticAction {
    static func live(
        arExtract: ArExtract = .live(),
        arArchive: ArArchive = .live(),
        getFiles: GetFiles = .live(),
        fileCheck: FileCheck = .live(),
        rename: MoveItem = .live(),
        rewriteBinary: TransmogrifierEdit = .live(),
        vRewriteBinary: VToolEdit = .live()
    ) -> Self {
        .init { current, libName, minos, sdk, log in
            guard let archived = try fileCheck(path: current.addingComponent(libName), log?.indented()),
                  archived == .staticBinary
            else {
                log?(.normal, "\(libName) is not thin static library")
                return
            }
            try arExtract(input: current.addingComponent(libName), log?.indented())
            let objects = try getFiles(searchPath: current, searchFile: "*.o", log?.indented())
            for objectPath in objects {
                guard let fileType = try fileCheck(path: objectPath, log?.indented()),
                      fileType == .machO64_Object
                else {
                    log?(.normal, "\(objectPath.string) is not Mach-O 64 Object")
                    return
                }
                do {
                    try rewriteBinary(
                        rewritePath: objectPath,
                        minos: minos,
                        sdk: sdk,
                        linkType: .static,
                        log?.indented())
                }
                catch let error as TransmogrifierError {
                    switch error {
                    case .alreadyProcessed:
                        log?(.verbose, "Found LC_BUILD_VERSION, try vtool replace IOSSIMULATOR(7)")
                        let renamed = Path(objectPath.string + "_old")
                        try rename(current: objectPath, destination: renamed, log?.indented())
                        try vRewriteBinary(
                            input: renamed,
                            output: objectPath,
                            minos: minos,
                            sdk: sdk,
                            log?.indented())
                    case .noSupportedFormat(let message):
                        log?.indented().callAsFunction(.verbose, message)
                        throw error
                    case .noCorrectBinary(let message):
                        log?.indented().callAsFunction(.verbose, message)
                        throw error
                    default:
                        throw error
                    }
                } catch {
                    throw error
                }
            }
            try rename(
                current: current.addingComponent(libName),
                destination: current.addingComponent(libName + ".old"),
                log?.indented()
            )
            try arArchive(output: current.addingComponent(libName), rewrited: objects, log?.indented())
        }
    }
}
