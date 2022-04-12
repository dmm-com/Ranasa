import ArgumentParser
import Foundation
import RanasaCore

enum InputOptionsError: Error {
    case output
}

struct Ranasa: ParsableCommand {
    static var ranasaCore: RanasaCore = .live()
    static var ranasaVerify: RanasaSettingPrinter = .live()
    static var ranasaReplacer: RanasaReplacer = .live()
    static var ranasaReverter: RanasaReverter = .live()

    static let configuration = CommandConfiguration(
        commandName: "ranasa",
        abstract: "`ranasa` is utility for switch architecture from legacy static library, static framework, dynamic library, dynamic framework.",
        discussion: """
        The design idea is to make binary libraries that depend on projects built with
        older designs compatible with Apple Silicon from the outside.
        
        For libraries that are Fat Architecture Binary,
        we can change them from arm64 and x86_64-simulator to arm64 and arm64-simulator
        and build them with arm64-Xcode and run them on arm64-simulator.
        You can build it with arm64-Xcode and run it on arm64-simulator.
        
        This tool can be recommended for projects that for some reason cannot support the xcframework,
        or where changing the packaging of the library would increase the man-hours.
        
        Input File Description
        - linking: type `static` or `dynamic`.
        - path: relative path, Source Root define `root` option.
        
        ```json
        [
            {
                "linking": "dynamic",
                "path":  "relative/path/to/library"
            },
            {
                "linking": "static",
                "path":  "relative/path/to/framework/in/library"
            },
        ]
        ```
        """,
        helpNames: [.short, .customLong("help")])

    @Argument(
        help: "Path of the definition file")
    var configFile: String
    
    @Option(
        name: [.short, .customLong("root")],
        help: ArgumentHelp("The location to root the library ")
    )
    var rootPath: String = "."

    @Option(
        name: [.short, .customLong("store")],
        help: ArgumentHelp("The location to store save the binary"))
    var storePath: String = FileManager.default.homeDirectoryForCurrentUser.relativePath + "/.ranasa"

    @Option(
        name: [.customLong("minos")],
        help: ArgumentHelp("Simulator minos variable number, default = 13.0"))
    var minos: Float?

    @Option(
        name: [.customLong("sdk")],
        help: ArgumentHelp("Simulator sdk variable number, default = 13.0"))
    var sdk: Float?
    
    @Flag(
        name: [.customShort("x"), .customLong("xcode")],
        help: ArgumentHelp("If in xcode script, auto detect simulator or actual. fall back to `simulator` flag."))
    var isXcodeScript: Bool = false
    
    @Flag(
        name: [.customShort("a"), .customLong("simulator")],
        help: ArgumentHelp("Replace binaries with simulator builds"))
    var isSimulator: Bool = false
    
    @Flag(
        name: [.customShort("t"), .customLong("thin")],
        help: ArgumentHelp("Output builds to arm64_simulator architecture only"))
    var isThin: Bool = false
    
    @Flag(
        name: [.customShort("k"), .customLong("original-revert")],
        help: ArgumentHelp("Revert placed binaries back to their original binaries"))
    var isRevert: Bool = false

    @Flag(
        name: [.short, .customLong("verbose")],
        help: ArgumentHelp("Log detailed info to standard output."))
    var verbose: Bool = false

    @Flag(
        name: [.customShort("c"), .customLong("check")],
        help: ArgumentHelp(
            "Display how ranasa recognizes the descriptions in the configuration file.",
            discussion: "Does not cause side effects. Only outputs the configuration file."
        ))
    var isOnlyCheck: Bool = false

    func run() throws {
        let log = verbose ? Log.live(level: .verbose) : nil
        
        try Self.ranasaVerify(
            at: Path(configFile),
            srcroot: Path(rootPath))
        if isOnlyCheck { return }
        
        if isRevert {
            try Self.ranasaReverter(
                at: Path(configFile),
                backup: Path(storePath),
                root: Path(rootPath),
                verbose: log)
            return
        }

        try Self.ranasaCore(
            at: Path(configFile),
            backup: Path(storePath),
            root: Path(rootPath),
            minos: minos,
            sdk: sdk,
            verbose: log)
        
        var isSim: Bool {
            if isXcodeScript,
               let value = ProcessInfo.processInfo.environment["SDKROOT"] {
                print("SDKROOT: \(value)")
                return value.contains("Simulator")
            } else {
                return isSimulator
            }
        }
        try Self.ranasaReplacer(
            at: Path(configFile),
            backup: Path(storePath),
            root: Path(rootPath),
            isThin: isThin,
            isSimulator: isSim,
            verbose: log)
        print("Completed!")
    }

}
