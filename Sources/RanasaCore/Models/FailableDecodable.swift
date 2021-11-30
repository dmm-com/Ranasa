public struct FailableDecodable<Unpack: Decodable>: Decodable {
    let unpack: Unpack?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.unpack = try? container.decode(Unpack.self)
    }
}
