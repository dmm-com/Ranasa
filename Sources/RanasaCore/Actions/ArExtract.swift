public struct ArExtract {
    var run: (Path, Log?) throws -> Void
    
    public func callAsFunction(input: Path, _ log: Log? = nil) throws {
        try run(input, log)
    }
}

public extension ArExtract {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { input, log in
            log?(.normal, "[Extract ar archive]")
            log?(.verbose, "- input: \(input.string)")
            log?(.verbose, "- base: \(input.basePath.string)")
            _ = try runShellCommand(baseDir: input.basePath.string, "ar xv \(input.lastComponent)", log?.indented())
        }
    }
}
