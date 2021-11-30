public struct GetArchs {
    var run: (Path, Log?) throws -> [Arch]
    
    public func callAsFunction(binaryPath: Path, _ log: Log? = nil) throws -> [Arch] {
        try run(binaryPath, log)
    }
}

public extension GetArchs {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { binaryPath, log in
            log?(.normal, "[Get Archs]")
            log?(.verbose, "- binary path : \(binaryPath.string)")
            let archs = try runShellCommand(
                "lipo -archs \(binaryPath.string)", log?.indented())
                .components(separatedBy: " ")
                .compactMap(Arch.init(rawValue:))
            log?(.verbose, "- archs: \(archs.map(\.rawValue).joined(separator: " "))")
            return archs
        }
    }
}
