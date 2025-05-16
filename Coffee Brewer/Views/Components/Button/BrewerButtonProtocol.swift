import SwiftUI

protocol BrewerButton: View {
    var title: String { get }
    var action: () -> Void { get }
    var maxWidth: CGFloat? { get }
}
