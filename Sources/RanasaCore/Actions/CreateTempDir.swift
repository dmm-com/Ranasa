import Foundation

public struct CreateTempDir {
    var run: (Log?) throws -> Path

    public func callAsFunction(_ log: Log? = nil) throws -> Path {
        try run(log)
    }
}

public extension CreateTempDir {
    static func live(
        basePath: Path = Path(FileManager.default.temporaryDirectory.path),
        randomString: @escaping () -> String = { UUID().uuidString },
        createDir: CreateDir = .live()
    ) -> Self {
        .init { log in
            log?(.normal, "[Create Temporary Directory]")
            let temporaryPath = basePath.addingComponent("ranasa_\(randomString())")
            try createDir(input: temporaryPath, log?.indented())
            log?(.verbose, "- temporary: \(temporaryPath.string)")
            return temporaryPath
        }
    }
}
