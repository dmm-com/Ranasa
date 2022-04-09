public struct DynamicAction {
    var run: (Path, String, Float?, Float?, Log?) throws -> Void
    
    public func callAsFunction(current: Path, libName: String, minos: Float?, sdk: Float?, _ log: Log? = nil) throws {
        try run(current, libName, minos, sdk, log)
    }
}

public extension DynamicAction {
    static func live(
        fileCheck: FileCheck = .live(),
        rename: MoveItem = .live(),
        tRewriteBinary: TransmogrifierEdit = .live(),
        vRewriteBinary: VToolEdit = .live()
    ) -> Self {
        .init { current, libName, minos, sdk, log in
            let path = current.addingComponent(libName)
            guard let archived = try fileCheck(path: path, log?.indented()),
                  archived == .dynamicBinary
            else {
                log?(.normal, "\(libName) is not thin static library")
                return
            }
            
            do {
                try tRewriteBinary(
                    rewritePath: path,
                    minos: minos,
                    sdk: sdk,
                    linkType: .dynamic,
                    log?.indented())
            }
            catch let error as TransmogrifierError {
                switch error {
                case .alreadyProcessed:
                    log?(.verbose, "Found LC_BUILD_VERSION, try vtool replace IOSSIMULATOR(7)")
                    let renamed = current.addingComponent(libName + "_old")
                    try rename(current: path, destination: renamed)
                    try vRewriteBinary(
                        input: renamed,
                        output: path,
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
    }
}
