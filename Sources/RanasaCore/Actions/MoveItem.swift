public struct MoveItem {
    var run: (Path, Path, Log?) throws -> Void
    
    public func callAsFunction(current: Path, destination: Path, _ log: Log? = nil) throws {
        try run(current, destination, log)
    }
}

public extension MoveItem {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { current, next, log in
            log?(.normal, "[Move File]")
            log?(.verbose, "- input current: \(current.string)")
            log?(.verbose, "- input next: \(next.string)")
            _ = try runShellCommand("mv -f \(current.string) \(next.string)", log?.indented())
        }
    }
}
