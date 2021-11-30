import Foundation

public enum DecodingSettingsError: Error {
    case fileNotFound(String)
}

public struct DecodeSettings {
    var run: (Path, Path, Log?) throws -> [FileStructure]
    
    public func callAsFunction(input: Path, srcroot: Path, _ log: Log? = nil) throws -> [FileStructure] {
        try run(input, srcroot, log)
    }
}

public extension DecodeSettings {
    static func live(
        decoder: JSONDecoder = JSONDecoder()
    ) -> Self {
        .init { input, srcroot, log in
            log?(.normal, "[Decode settings]")
            log?(.verbose, "- input: \(input.string)")
            let defineData = try Data(contentsOf: input.url)
            let settings = try decoder
                .decode([FailableDecodable<FileStructure>].self, from: defineData)
                .compactMap(\.unpack)
            return settings.map { (setting: FileStructure) -> FileStructure in
                return FileStructure(
                    path: srcroot.addingComponent(setting.path.string),
                    linking: setting.linking)
            }
        }
    }
}
