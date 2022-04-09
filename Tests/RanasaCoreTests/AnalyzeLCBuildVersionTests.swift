import XCTest
@testable import RanasaCore

final class AnalyzeLCBuildVersionTests: XCTestCase {
    func testAnalyzeNtool1() throws {
        let command: AnalyzeLCBuildVersion = .live(runShellCommand: .init(run: { _, _, _ in
            return """
            arm64_simulator/lib (architecture arm64):
            Load command 10
                  cmd LC_BUILD_VERSION
              cmdsize 32
             platform IOS
                minos 13.0
                  sdk 15.2
               ntools 1
                 tool LD
              version 711.0
            Load command 11
                  cmd LC_SOURCE_VERSION
              cmdsize 16
              version 0.0
            """
        }))
        let output = try command(input: .init(""))
        XCTAssertEqual(output.platform, .ios)
        XCTAssertEqual(output.minos, 13.0)
        XCTAssertEqual(output.sdk, 15.2)
        XCTAssertEqual(output.ntool, 1)
        XCTAssertEqual(output.tool, .ld)
        XCTAssertEqual(output.toolVersion, 711.0)
    }
    
    func testAnalyzeNtool0() throws {
        let command: AnalyzeLCBuildVersion = .live(runShellCommand: .init(run: { _, _, _ in
            return """
            arm64_simulator/lib (architecture arm64):
            Load command 10
                  cmd LC_BUILD_VERSION
              cmdsize 32
             platform IOS
                minos 13.0
                  sdk 15.2
               ntools 0
            Load command 11
                  cmd LC_SOURCE_VERSION
              cmdsize 16
              version 0.0
            """
        }))
        let output = try command(input: .init(""))
        XCTAssertEqual(output.platform, .ios)
        XCTAssertEqual(output.minos, 13.0)
        XCTAssertEqual(output.sdk, 15.2)
        XCTAssertEqual(output.ntool, 0)
        XCTAssertEqual(output.tool, nil)
        XCTAssertEqual(output.toolVersion, nil)
    }
}
