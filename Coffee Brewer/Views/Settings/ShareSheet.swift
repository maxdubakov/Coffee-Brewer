import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let fileName: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Create a temporary file URL with the proper filename
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        if let data = items.first as? Data {
            try? data.write(to: tempURL)
            let controller = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            return controller
        }
        
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
