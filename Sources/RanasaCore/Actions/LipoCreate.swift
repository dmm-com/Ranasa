public struct LipoCreate {
    var run: ([Path], Path, Log?) throws -> Void
    
    public func callAsFunction(inputs: [Path], output: Path, _ log: Log? = nil) throws {
        try run(inputs, output, log)
    }
}

public extension LipoCreate {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { (input: [Path], output: Path, log: Log?) in
            let inputs = input.map(\.string)
            log?(.normal, "[Create fat binary]")
            log?(.verbose, "- inputs : \(inputs.joined(separator: " "))")
            log?(.verbose, "- output : \(output.string)")
            let builded = ([
                "lipo",
                "-create",
                "-output \(output.string)"
            ] + inputs).joined(separator: " ")
            log?(.verbose, "command: \(builded)")
            _ = try runShellCommand(builded, log?.indented())
        }
    }
}
