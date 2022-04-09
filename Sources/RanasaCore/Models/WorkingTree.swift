public enum WorkingTree: String, CaseIterable {
    /// original binary
    case original
    /// copy original library
    case arm64
    /// rewrited library
    case arm64_simulator
    /// working directory base path
    case working
    /// working thin library
    case thin
    /// working extract library
    case extract
    
    func path(base: Path) -> Path {
        switch self {
        case .arm64, .arm64_simulator, .working, .original:
            return base.addingComponent(rawValue)
        case .thin, .extract:
            return base
                .addingComponent(Self.working.rawValue)
                .addingComponent(rawValue)
        }
    }
}

public extension Path {
    func treePath(_ leaf: WorkingTree) -> Path {
        return leaf.path(base: self)
    }
}
