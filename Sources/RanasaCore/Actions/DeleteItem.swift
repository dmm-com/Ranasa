public struct DeleteItem {
    var run: (Path, Log?) throws -> Void
    
    public func callAsFunction(input: Path, _ log: Log? = nil) throws {
        try run(input, log)
    }
}

public extension DeleteItem {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { input, log in
            log?(.normal, "[Delete File]")
            log?(.verbose, "- input: \(input.string)")
            _ = try runShellCommand("rm -Rf \(input.string)", log?.indented())
        }
    }
}
