import XCTest
@testable import RanasaCore

final class LogTests: XCTestCase {
    func testLevelNormalLogging() {
        var output = [String]()
        let sut: Log = .live(
            level: .normal,
            print: { output.append($0) }
        )

        sut(.normal, "normal")
        sut(.verbose, "no output")

        XCTAssertEqual(output, ["normal"])
    }

    func testLevelVerboseLogging() {
        var output = [String]()
        let sut: Log = .live(
            level: .verbose,
            print: { output.append($0) }
        )

        sut(.normal, "normal")
        sut(.verbose, "verbose")

        XCTAssertEqual(output, [
            "normal",
            "verbose"
        ])
    }

    func testOutputIndentedLogging() {
        var output = [String]()
        let sut: Log = .live(
            level: .normal,
            print: { output.append($0) }
        ).indented()

        sut(.normal, "first\nsecond\nthird")

        XCTAssertEqual(output, ["|\tfirst\n|\tsecond\n|\tthird"])
    }
}
