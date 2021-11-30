public struct LipoThin {
    var run: (Path, Arch, Path, Log?) throws -> Void
    
    public func callAsFunction(input: Path, arch: Arch, output: Path, _ log: Log? = nil) throws {
        try run(input, arch, output, log)
    }
}

public extension LipoThin {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { input, arch, output, log in
            log?(.normal, "[Thin binary architecture]")
            log?(.verbose, "- input: \(input.string)")
            log?(.verbose, "- arch: \(arch.rawValue)")
            log?(.verbose, "- output: \(output.string)")
            let thinX = "-thin \(arch.rawValue)"
            let outputX = "-output \(output.string)"
            let builded = [
                "lipo",
                input.string,
                thinX,
                outputX
            ].joined(separator: " ")
            log?(.verbose, "command: \(builded)")
            _ = try runShellCommand(builded, log?.indented())
        }
    }
}
