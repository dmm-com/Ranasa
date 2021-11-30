public struct FileCheck {
    var run: (Path, Log?) throws -> FileType?
    
    public func callAsFunction(path: Path, _ log: Log? = nil) throws -> FileType? {
        try run(path, log)
    }
}

public extension FileCheck {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { path,  log in
            log?(.normal, "[File Check]")
            log?(.verbose, "- input : \(path.string)")
            let type = try runShellCommand("file -b \(path.string)", log?.indented())
                .split(whereSeparator: \.isNewline).first
                .flatMap(FileType.init(rawValue:))
            return type
        }
    }
}
