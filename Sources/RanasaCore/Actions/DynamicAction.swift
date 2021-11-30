public struct DynamicAction {
    var run: (Path, String, Int, Int, Log?) throws -> Void
    
    public func callAsFunction(current: Path, libName: String, minos: Int, sdk: Int, _ log: Log? = nil) throws {
        try run(current, libName, minos, sdk, log)
    }
}

public extension DynamicAction {
    static func live(
        fileCheck: FileCheck = .live(),
        rename: MoveItem = .live(),
        rewriteBinary: TransmogrifierEdit = .live()
//        rewriteBinary: VToolEdit = .live()
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
                try rewriteBinary(
                    rewritePath: path,
                    minos: minos,
                    sdk: sdk,
                    linkType: .static,
                    log?.indented())
            }
            catch let error as TransmogrifierError {
                switch error {
                case .alreadyProcessed:
                    log?.indented().callAsFunction(.verbose, "- 🍎 \(path.string) is already simulator object")
                case .noSupportedFormat(let message):
                    log?.indented().callAsFunction(.verbose, message)
                    fatalError(message)
                case .noCorrectBinary(let message):
                    log?.indented().callAsFunction(.verbose, message)
                    fatalError(message)
                default:
                    fatalError("Unintentional errors, Path not found")
                }
            } catch {
                throw error
            }
            
//            let renamed = current.addingComponent(libName).addingComponent("old")
//            try rename(current: current.addingComponent(libName), destination: renamed)
//            try rewriteBinary(
//                input: renamed,
//                output: current.addingComponent(libName),
//                minos: minos,
//                sdk: sdk,
//                log?.indented())
        }
    }
}
