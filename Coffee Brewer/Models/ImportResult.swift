import Foundation

struct ImportResult {
    let isSuccess: Bool
    let error: Error?
    let imported: [String: Int]
    let ignored: [String: Int]
    
    var totalImported: Int {
        imported.values.reduce(0, +)
    }
    
    var totalIgnored: Int {
        ignored.values.reduce(0, +)
    }
    
    var hasData: Bool {
        totalImported > 0 || totalIgnored > 0
    }
    
    static func success(imported: [String: Int], ignored: [String: Int]) -> ImportResult {
        ImportResult(isSuccess: true, error: nil, imported: imported, ignored: ignored)
    }
    
    static func failure(error: Error) -> ImportResult {
        ImportResult(isSuccess: false, error: error, imported: [:], ignored: [:])
    }
}

struct ImportCounter {
    private var imported: [String: Int] = [:]
    private var ignored: [String: Int] = [:]
    
    mutating func incrementImported(_ entityType: String) {
        imported[entityType, default: 0] += 1
    }
    
    mutating func incrementIgnored(_ entityType: String) {
        ignored[entityType, default: 0] += 1
    }
    
    func result() -> (imported: [String: Int], ignored: [String: Int]) {
        return (imported, ignored)
    }
}