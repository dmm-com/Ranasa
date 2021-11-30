public struct BinaryReplace {
    var run: (FileStructure, Path, Log?) throws -> Void
    
    public func callAsFunction(setting: FileStructure, input: Path, _ log: Log? = nil) throws {
        try run(setting, input, log)
    }
}

public extension BinaryReplace {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { setting, input, log in
            log?(.normal, "[Binary Replace]")
            log?(.verbose, "- input: \(input.string)")
            log?(.verbose, "- setting path: \(setting.path.string)")
            log?(.verbose, "- setting link: \(setting.linking.rawValue)")
            _ = try runShellCommand("rm -f \(setting.path.string)", log?.indented())
            _ = try runShellCommand("cp -f \(input.string) \(setting.path.string)", log?.indented())
        }
    }
}
