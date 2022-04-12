public struct VToolEdit {
    var run: (Path, Path, Float?, Float?, Log?) throws -> Void
    
    public func callAsFunction(
        input: Path,
        output: Path,
        minos: Float?,
        sdk: Float?,
        _ log: Log? = nil) throws {
        try run(input, output, minos, sdk, log)
    }
}

public extension VToolEdit {
    static func live(
        checkLCBuildVersion: AnalyzeLCBuildVersion = .live(),
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { input, output, minos, sdk, log in
            log?(.normal, "[Rewrite LC_Build_Version]")
            log?(.verbose, "- input: \(input.string)")
            log?(.verbose, "- output: \(output.string)")
            
            let analyzed = try checkLCBuildVersion(input: input, log?.indented())
            
            let archX = "-arch arm64"
            let buildVersionX = "-set-build-version \(analyzed.platform.toSimValue) \(minos ?? analyzed.minos) \(sdk ?? analyzed.sdk)"
            let toolX = analyzed.ntool >= 1 ? "-tool \(analyzed.tool!.intValue) \(analyzed.toolVersion!)" : ""
            let replaceX = "-replace"
            let outputX = "-output \(output.string)"
            let builded = [
                "vtool",
                archX,
                buildVersionX,
                toolX,
                replaceX,
                outputX,
                input.string
            ].joined(separator: " ")
            _ = try runShellCommand(builded, log?.indented())
        }
    }
}
