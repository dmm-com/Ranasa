import XCTest
@testable import RanasaCore

final class VToolEditTests: XCTestCase {
    func testVToolEdit() throws {
        let command: VToolEdit = .live(
            checkLCBuildVersion: .live(runShellCommand: .init(run: { _, _, _ in
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
            })),
            runShellCommand: .live(shExecuter: { command, pos in
                print("Publish: \(command)")
                print("Position: \(pos ?? "")")
                return ""
            }))
        try command(input: .init("input"), output: .init("output"), minos: 123, sdk: 689, .live(level: .verbose))
    }
}
