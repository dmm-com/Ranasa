import Foundation

/// Reference code for the string coming out of "file command"
/// Example: `file -b <filename>`
public enum FileType: String, Equatable, CaseIterable, CustomStringConvertible {
    /// Fat architecture binary
    case universalBinary = "Mach-O universal binary with"
    /// Thin archtecture binary of static
    case staticBinary = "current ar archive"
    /// Static library object
    case machO64_Object = "Mach-O 64-bit object arm64"
    /// Thin archtecture binary of dynamic
    case dynamicBinary = "Mach-O 64-bit dynamically linked shared library arm64"
    
    public init?<T: StringProtocol>(rawValue: T) {
        let rawValue = String(rawValue)
        let matched: [FileType] = Self.allCases
            .compactMap { rawValue.contains($0.rawValue) ? $0 : nil }
        if let matchType = matched.first {
            self = matchType
        } else {
            return nil
        }
    }
    
    public var description: String {
        return self.rawValue
    }
}
