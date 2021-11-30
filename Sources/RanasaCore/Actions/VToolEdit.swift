public struct VToolEdit {
    var run: (Path, Path, Int, Int, Log?) throws -> Void
    
    public func callAsFunction(
        input: Path,
        output: Path,
        minos: Int,
        sdk: Int,
        _ log: Log? = nil) throws {
        try run(input, output, minos, sdk, log)
    }
}

public extension VToolEdit {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { input, output, minos, sdk, log in
            let archX = "-arch arm64"
            let buildVersionX = "-set-build-version 7 \(minos) \(sdk)"
            let replaceX = "-replace"
            let outputX = "-output \(output.string)"
            log?(.normal, "[Rewrite Dynamic Library]")
            log?(.verbose, "- input: \(input.string)")
            log?(.verbose, "- arch: arm64")
            log?(.verbose, "- build-version: 7 \(minos) \(sdk)")
            log?(.verbose, "- relace: on")
            log?(.verbose, "- output: \(output.string)")
            let builded = [
                "vtool",
                archX,
                buildVersionX,
                replaceX,
                outputX,
                input.string
            ].joined(separator: " ")
            log?(.verbose, "command: \(builded)")
            _ = try runShellCommand(builded, log?.indented())
        }
    }
}
