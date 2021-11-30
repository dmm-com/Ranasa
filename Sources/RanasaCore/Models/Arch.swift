public enum Arch: String, CustomStringConvertible {
    case i386
    case x86_64
    case armv7
    case armv7s
    case arm64
    
    public var description: String {
        return self.rawValue
    }
}
