public enum AnalyzeLCBuildVersionError: Error {
    case notFoundKeyLCBuildVersion
}

public struct AnalyzeLCBuildVersion {
    var run: (Path, Log?) throws -> LCBuildVersion
    
    public func callAsFunction(input: Path, _ log: Log? = nil) throws -> LCBuildVersion {
            try run(input, log)
        }
}

public extension AnalyzeLCBuildVersion {
    static func live(
        runShellCommand: RunShellCommand = .live()
    ) -> Self {
        .init { input, log in
            log?(.normal, "[Check LC_BUILD_VERSION]")
            log?(.verbose, "- input: \(input.string)")
            let output = try runShellCommand("vtool -arch arm64 -show \(input.string)", log?.indented())
            var kv: [String:String] = [:]
            var focusPoint = false
            for line in output.components(separatedBy: .newlines) {
                let g = line
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .components(separatedBy: .whitespaces)
                if g.count == 2 {
                    if g[0] == "cmd" && g[1] == "LC_BUILD_VERSION" {
                        focusPoint = true
                    } else if g[0] == "cmd" {
                        focusPoint = false
                    }
                    if focusPoint {
                        kv[g[0]] = g[1]
                    }
                }
            }
            
            guard
                let platform = VToolOption.Platform(strValue: kv["platform"] ?? ""),
                let minos = Float(kv["minos"] ?? ""),
                let sdk = Float(kv["sdk"] ?? ""),
                let ntool = Int(kv["ntools"] ?? "")
            else {
                throw AnalyzeLCBuildVersionError.notFoundKeyLCBuildVersion
            }
            
            return .init(
                platform: platform,
                minos: minos,
                sdk: sdk,
                ntool: ntool,
                tool: .init(strValue: kv["tool"] ?? ""),
                toolVersion: Float(kv["version"] ?? ""))
        }
    }
}
