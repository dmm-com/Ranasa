public struct TransmogrifierEdit {
    var run: (Path, Float?, Float?, LinkType, Log?) throws -> Void
    
    public func callAsFunction(
        rewritePath input: Path,
        minos: Float?,
        sdk: Float?,
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
            log?(.verbose, "- minos : \(minos ?? 13)")
            log?(.verbose, "- sdk : \(sdk ?? 13)")
            try Transmogrifier.processBinary(atPath: input.string, minos: minos.flatMap(UInt32.init) ?? 13, sdk: sdk.flatMap(UInt32.init) ?? 13, isDynamic: linkType == .dynamic)
        }
    }
}
