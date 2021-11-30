public struct GetFiles {
    var run: (Path, String, Log?) throws -> [Path]
    
    public func callAsFunction(searchPath: Path, searchFile: String, _ log: Log? = nil) throws -> [Path] {
        try run(searchPath, searchFile, log)
    }
}

public extension GetFiles {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { searchPath, searchFile, log in
            log?(.normal, "[Get Files]")
            log?(.verbose, "- search path : \(searchPath.string)")
            log?(.verbose, "- search file : \(searchFile)")
            let files = try runShellCommand(
                "ls \(searchPath.string)/\(searchFile)", log?.indented())
                .components(separatedBy: "\n")
                .compactMap(Path.init)
            files.forEach { file in
                log?(.verbose, "- files: \(file.string)")
            }
            return files
        }
    }
}
