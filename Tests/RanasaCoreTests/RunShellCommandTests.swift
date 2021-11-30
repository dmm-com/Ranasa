import XCTest
@testable import RanasaCore

final class RunShellCommandTests: XCTestCase {
    enum Action: Equatable {
        case didShellOut(String)
        case didLog(LogLevel, String)
    }
    
    static let rootDir = "/Root"
    static let inCommand = "stub command name"
    static let outCommand = "mock output string"
    var didEffects = [Action]()
    
    override func setUp() {
        didEffects.removeAll()
    }
    
    func testExecuteCommand() throws {
        let sut: RunShellCommand = .live { [self] command, _  in
            self.didEffects.append(.didShellOut(command))
            return Self.outCommand
        }
        
        let log: Log = .init { level, message in
            self.didEffects.append(.didLog(level, message))
        }
        
        let result = try sut(baseDir: Self.rootDir ,Self.inCommand, log)
        
        XCTAssertEqual(didEffects, [
            .didLog(.normal, "[Execute Command]"),
            .didLog(.verbose, "- run Directory: \(Self.rootDir)"),
            .didLog(.verbose, "- command: \(Self.inCommand)"),
            .didShellOut(Self.inCommand),
            .didLog(.verbose, "- output: \(Self.outCommand)")
        ])
        XCTAssertEqual(result, Self.outCommand)
    }
}
