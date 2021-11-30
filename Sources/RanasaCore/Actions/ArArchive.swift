public struct ArArchive {
    var run: (Path, [Path], Log?) throws -> Void
    
    public func callAsFunction(output: Path, rewrited objects: [Path], _ log: Log? = nil) throws {
        try run(output, objects, log)
    }
}

public extension ArArchive {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { output, objects, log in
            log?(.normal, "[Archive object file to ar file]")
            objects.forEach { object in
                log?(.verbose, "- contained object: \(object.string)")
            }
            log?(.verbose, "- output: \(output.string)")
            _ = try runShellCommand("ar crv \(output.string) \(objects.map(\.string).joined(separator: " "))", log?.indented())
        }
    }
}
