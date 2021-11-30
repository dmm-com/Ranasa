import XCTest
@testable import RanasaCore

final class DecodeSettingsTests: XCTestCase {
    
    
    /// miss - linking value is other, the correct values are dynamic and static.
    /// miss - keyName is paths, the correct value is path.
    /// {
    ///   "linking": "dynamic" or "static",
    ///   "path": "<some string value>"
    /// }
    static let json = """
    [
        {"linking": "dynamic",  "path":  "path/to/dlibrary"},
        {"linking": "static",   "path":  "path/to/slibrary"},
        {"linking": "dynamic",  "paths": "path/to/none"},
        {"linking": "other",    "path":  "path/to/other"},
        {"linking": "dynamic",  "path":  "path/to/3"}
    ]
    """
    
    let decodingSetting: DecodeSettings = .live()
    
    var actualPath: URL!
    
    override func setUp() {
        actualPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("settings.json")
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: actualPath)
    }
    
    func testDecodeSetting() {
        try! Self.json.write(to: actualPath, atomically: false, encoding: .utf8)
        
        let settings = try? decodingSetting(input: Path(actualPath.path), srcroot: Path("/Root"), nil)
        XCTAssertNotNil(settings)
        
        guard let settings = settings else { return }
        XCTAssertEqual(settings[0].path, Path("/Root/path/to/dlibrary"))
        XCTAssertEqual(settings[0].linking, .dynamic)
        
        XCTAssertEqual(settings[1].path, Path("/Root/path/to/slibrary"))
        XCTAssertEqual(settings[1].linking, .static)
        
        XCTAssertEqual(settings[2].path, Path("/Root/path/to/3"))
        XCTAssertEqual(settings[2].linking, .dynamic)
        
        XCTAssertEqual(settings.count, 3)
    }
}
