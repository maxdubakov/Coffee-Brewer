import SwiftUI

extension String {
    /// Returns a pluralized string based on the count
    /// Example: "pour".pluralized(count: 1) returns "1 pour"
    /// Example: "pour".pluralized(count: 3) returns "3 pours"
    static func pluralized(_ word: String, count: Int) -> String {
        return "^[\(count) \(word)](inflect: true)"
    }
}

extension Text {
    /// Creates a Text view with automatic pluralization
    /// Example: Text.pluralized("pour", count: 1) returns Text("1 pour")
    /// Example: Text.pluralized("pour", count: 3) returns Text("3 pours")
    static func pluralized(_ word: String, count: Int) -> Text {
        return Text("^[\(count) \(word)](inflect: true)")
    }
}