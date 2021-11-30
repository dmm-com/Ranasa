public struct CodeSign {
    var run: (Path, Log?) throws -> Void
    
    public func callAsFunction(input: Path, _ log: Log? = nil) throws {
        try run(input, log)
    }
}

public extension CodeSign {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { input, log in
            log?(.normal, "[CodeSigning]")
            log?(.verbose, "- input: \(input.string)")
            _ = try runShellCommand("codesign --sign - \(input.string)", log?.indented())
        }
    }
}
