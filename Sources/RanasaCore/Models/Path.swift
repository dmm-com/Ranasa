import Foundation

public struct Path: Equatable, Hashable {
    public init(_ string: String) {
        self.string = string
    }
    
    var string: String
}

extension Path {
    var lastComponent: String {
        string.split(separator: "/").last.map(String.init) ?? ""
    }
    
    var basePath: Path {
        Path(String(string.dropLast(lastComponent.count + 1)))
    }
    
    var url: URL {
        URL(fileURLWithPath: string)
    }
    
    func addingComponent(_ component: String) -> Path {
        var newPath = Path(string)
        if !string.hasSuffix("/") {
            newPath.string.append("/")
        }
        newPath.string.append(component)
        return newPath
    }
}

extension Path: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        string = try container.decode(String.self)
    }
}
