import XCTest
@testable import RanasaCore

final class GetFilesTests: XCTestCase {
    func testGetFiles() throws {
        let command: GetFiles = .live(
            runShellCommand: .live(
                shExecuter: { command, _ in
                    """
                    target1.o
                    target2.o
                    target3.o
                    """
                }))
        let files = try command(searchPath: .init("."), searchFile: "", .live(level: .verbose))
        XCTAssertEqual(files.count, 3)
        XCTAssertEqual(files[0].string, "target1.o")
        XCTAssertEqual(files[1].string, "target2.o")
        XCTAssertEqual(files[2].string, "target3.o")
    }
}
