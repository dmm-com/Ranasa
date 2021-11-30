public struct LipoExtract {
    var run: (Path, [Arch], Path, Log?) throws -> Void
    
    public func callAsFunction(
        input: Path,
        archs: [Arch],
        output: Path,
        _ log: Log? = nil) throws {
        try run(input, archs, output, log)
    }
}

public extension LipoExtract {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { input, archs, output, log in
            log?(.normal, "[Extract fat binary]")
            log?(.verbose, "- input : \(input.string)")
            log?(.verbose, "- archs : \(archs.map(\.rawValue).joined(separator: " "))")
            log?(.verbose, "- output : \(output.string)")
            let builded = [
                "lipo",
                "-output \(output.string)",
                archs.map({ "-extract \($0)"}).joined(separator: " "),
                input.string
            ].joined(separator: " ")
            log?(.verbose, "command: \(builded)")
            _ = try runShellCommand(builded, log?.indented())
        }
    }
}
