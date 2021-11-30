public struct Log {
    var run: (LogLevel, String) -> Void
    
    public func callAsFunction(_ level: LogLevel, _ message: String) {
        run(level, message)
    }
}

public extension Log {
    static func live(
        level loggingLevel: LogLevel = .normal,
        print: @escaping (String) -> Void = { print($0) }
    ) -> Self {
        .init { level, message in
            guard level <= loggingLevel else { return }
            print(message)
        }
    }
}

public extension Log {
    func indented() -> Self {
        .init { level, message in
            let indentation = "|\t"
            let indentedMessage = message
                .split(separator: "\n")
                .map { indentation + $0 }
                .joined(separator: "\n")
            self.callAsFunction(level, indentedMessage)
        }
    }
}
