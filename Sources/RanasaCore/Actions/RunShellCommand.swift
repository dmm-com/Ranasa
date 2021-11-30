import ShellOut
import Foundation

public struct RunShellCommand {
    var run: (String, String?, Log?) throws -> String
    
    public func callAsFunction(baseDir: String? = nil, _ command: String, _ log: Log? = nil) throws -> String {
        try run(command, baseDir, log)
    }
}

public struct ReShellOutError: Swift.Error {
    public let shellOutError: ShellOutError
    public init(shellOutError: ShellOutError) {
        self.shellOutError = shellOutError
    }
}

extension ReShellOutError: CustomStringConvertible {
    public var description: String {
        return [
        """
        \(shellOutError.message)
        """,
        !shellOutError.output.isEmpty ?
        """
        Output: "\(shellOutError.output)"
        """ :
        "",
        """
        Status code: \(shellOutError.terminationStatus)
        """
        ].joined(separator: "\n")
    }
}

extension ReShellOutError: LocalizedError {
    public var errorDescription: String? {
        return description
    }
}

public extension RunShellCommand {
    static func live(
        shExecuter: @escaping (String, String?) throws -> String = {
            do { return try shellOut(to: $0, at: $1 ?? ".") }
            catch let error as ShellOutError { throw ReShellOutError(shellOutError: error) }
            catch { throw error }
        }
    ) -> Self {
        .init { command, base, log in
            log?(.normal, "[Execute Command]")
            log?(.verbose, "- run Directory: \(base ?? ".")")
            log?(.verbose, "- command: \(command)")
            let output = try shExecuter(command, base)
            log?(.verbose, "- output: \(output)")
            return output
        }
    }
}
