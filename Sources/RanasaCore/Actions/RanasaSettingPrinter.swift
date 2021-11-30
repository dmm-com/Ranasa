import Foundation

public struct RanasaSettingPrinter {
    var run: (Path, Path, Log?) throws -> Void
    
    public func callAsFunction(at path: Path, srcroot: Path, verbose: Log? = nil) throws {
        try run(path, srcroot, verbose)
    }
}

public extension RanasaSettingPrinter {
    static func live(
        decodeSetting: DecodeSettings = .live()
    ) -> Self {
        .init { path, srcroot, log in
            let settings = try decodeSetting(input: path, srcroot: srcroot, log)
            print("-------------------------------------")
            for setting in settings {
                print(" - path    : \(setting.path.string)")
                print(" - linking : \(setting.linking.rawValue)")
                print("-------------------------------------")
            }
        }
    }
}
