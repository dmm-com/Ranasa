public struct CreateDir {
    var run: (Path, Log?) throws -> Void
    
    public func callAsFunction(input: Path, _ log: Log? = nil) throws {
        try run(input, log)
    }
}

public extension CreateDir {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { input, log in
            log?(.normal, "[Create Directory]")
            log?(.verbose, "- input: \(input)")
            _ = try runShellCommand("mkdir -p \(input.string)", log?.indented())
        }
    }
}
