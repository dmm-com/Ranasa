public struct TransmogrifierEdit {
    var run: (Path, Int, Int, LinkType, Log?) throws -> Void
    
    public func callAsFunction(
        rewritePath input: Path,
        minos: Int,
        sdk: Int,
        linkType: LinkType,
        _ log: Log? = nil) throws {
        try run(input, minos, sdk, linkType, log)
    }
}

public extension TransmogrifierEdit {
    static func live() -> Self {
        .init { input, minos, sdk, linkType, log in
            log?(.normal, "[👼 Rewrite \(input.lastComponent)]")
            log?(.verbose, "- input : \(input.string)")
            log?(.verbose, "- minos : \(minos)")
            log?(.verbose, "- sdk : \(sdk)")
            try Transmogrifier.processBinary(atPath: input.string, minos: UInt32(minos), sdk: UInt32(sdk), isDynamic: linkType == .dynamic)
        }
    }
}
