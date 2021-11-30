public struct CopyItem {
    var run: (Path, Path, Log?) throws -> Void
    
    public func callAsFunction(current: Path, destination: Path, _ log: Log? = nil) throws {
        try run(current, destination, log)
    }
}

public extension CopyItem {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { current, next, log in
            log?(.normal, "[Copy File]")
            log?(.verbose, "- input current: \(current.string)")
            log?(.verbose, "- input next: \(next.string)")
            _ = try runShellCommand("cp -Rf \(current.string) \(next.string)", log?.indented())
        }
    }
}
