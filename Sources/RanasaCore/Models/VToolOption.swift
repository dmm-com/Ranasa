enum VToolOption {
    enum Platform: Equatable {
        case macos
        case ios
        case tvos
        case watchos
        case bridgeos
        case maccatalyst
        case iossim
        case tvsim
        case watchossim
        case driverkit
        case firmware
        case sepos
        case undefine(Int)
        
        var intValue: Int {
            switch self {
            case .macos:
                return 1
            case .ios:
                return 2
            case .tvos:
                return 3
            case .watchos:
                return 4
            case .bridgeos:
                return 5
            case .maccatalyst:
                return 6
            case .iossim:
                return 7
            case .tvsim:
                return 8
            case .watchossim:
                return 9
            case .driverkit:
                return 10
            case .firmware:
                return 13
            case .sepos:
                return 14
            case .undefine(let n):
                return n
            }
        }
        
        var toSimValue: Int {
            switch self {
            case .ios:
                return Self.iossim.intValue
            case .tvos:
                return Self.tvsim.intValue
            case .watchos:
                return Self.watchossim.intValue
            default:
                return self.intValue
            }
        }
        
        init?(strValue: String) {
            switch strValue {
            case "MACOS":
                self = .macos
            case "IOS":
                self = .ios
            case "TVOS":
                self = .tvos
            case "WATCHOS":
                self = .watchos
            case "BRIDGEOS":
                self = .bridgeos
            case "MACCATALYST":
                self = .maccatalyst
            case "IOSSIMULATOR":
                self = .iossim
            case "TVOSSIMULATOR":
                self = .tvsim
            case "WATCHOSSIMULATOR":
                self = .watchossim
            case "DRIVERKIT":
                self = .driverkit
            case "FIRMWARE":
                self = .firmware
            case "SEPOS":
                self = .sepos
            default:
                if let i = Int(strValue) {
                    self = .undefine(i)
                } else {
                    return nil
                }
            }
        }
    }
    
    enum Tool: Equatable {
        case clang
        case swift
        case ld
        case undefine(Int)
        
        var intValue: Int {
            switch self {
            case .clang:
                return 1
            case .swift:
                return 2
            case .ld:
                return 3
            case .undefine(let n):
                return n
            }
        }
        
        init?(strValue: String) {
            switch strValue {
            case "CLANG":
                self = .clang
            case "SWIFT":
                self = .swift
            case "LD":
                self = .ld
            default:
                if let i = Int(strValue) {
                    self = .undefine(i)
                } else {
                    return nil
                }
            }
        }
    }
}
