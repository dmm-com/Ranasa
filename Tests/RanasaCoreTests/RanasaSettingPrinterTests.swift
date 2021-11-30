import XCTest
@testable import RanasaCore

final class RanasaSettingPrinterTests: XCTestCase {
    
    func testRanasaSettingPrinterPrint() {
        let verifyProcess: RanasaSettingPrinter = .live(decodeSetting: .preview)
        try! verifyProcess(at: .init(""), srcroot: .init(""),verbose: nil)
    }
}

extension DecodeSettings {
    static var preview: Self {
        .init { _, _, _  in
            return [
                FileStructure(
                    path: .init("/path/to/one"),
                    linking: .static),
                FileStructure(
                    path: .init("/path/to/two"),
                    linking: .static),
                FileStructure(
                    path: .init("/path/to/three"),
                    linking: .dynamic),
                FileStructure(
                    path: .init("/path/to/four"),
                    linking: .dynamic),
            ]
        }
    }
}
