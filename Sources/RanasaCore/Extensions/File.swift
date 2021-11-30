import Foundation

public extension FileManager {
    func dirExists(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        self.fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}
