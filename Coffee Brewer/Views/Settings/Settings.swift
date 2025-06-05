import SwiftUI

struct Settings: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var brews: FetchedResults<Brew>
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var roasters: FetchedResults<Roaster>
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var grinders: FetchedResults<Grinder>
    
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var exportData: Data?
    @State private var exportFileName = ""
    
    var body: some View {
        GlobalBackground {
            VStack(spacing: 0) {
                // Fixed header
                VStack(spacing: 0) {
                    PageTitleH1("Settings", subtitle: "Manage your coffee data")
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                // Scrollable content
                ScrollView {
                    VStack(spacing: 32) {
                        // Data Management Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Data Management")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(BrewerColors.textPrimary)
                            
                            VStack(spacing: 12) {
                                // Export Data
                                SettingsRow(
                                    icon: "square.and.arrow.up",
                                    title: "Export Data",
                                    subtitle: "Save your coffee data",
                                    action: handleExport
                                )
                                
                                CustomDivider()
                                    .padding(.horizontal, 20)
                                
                                // Import Data
                                SettingsRow(
                                    icon: "square.and.arrow.down",
                                    title: "Import Data",
                                    subtitle: "Restore from backup",
                                    action: { showingImportPicker = true }
                                )
                            }
                        }
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("About")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(BrewerColors.textPrimary)
                            
                            VStack(spacing: 12) {
                                // Version
                                AboutRow(
                                    title: "Version",
                                    value: "1.0.0"
                                )
                                
                                CustomDivider()
                                    .padding(.horizontal, 20)
                                
                                // Developer
                                AboutRow(
                                    title: "Developer",
                                    value: "Coffee Brewer Team"
                                )
                            }
                        }
                        
                        // Add extra space at bottom for tab bar
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let exportData = exportData {
                ShareSheet(items: [exportData], fileName: exportFileName)
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result: result)
        }
    }
    
    
    private func handleExport() {
        // TODO: Implement actual export logic
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        exportFileName = "CoffeeBrewerBackup_\(dateString).json"
        
        // For now, create a simple export structure
        let exportDict: [String: Any] = [
            "version": "1.0",
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "statistics": [
                "recipes": recipes.count,
                "brews": brews.count,
                "roasters": roasters.count,
                "grinders": grinders.count
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportDict, options: .prettyPrinted) {
            exportData = jsonData
            showingExportSheet = true
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        // TODO: Implement actual import logic
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            // Import logic will go here
            print("Selected file: \(url)")
        case .failure(let error):
            print("Import error: \(error)")
        }
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(BrewerColors.caramel)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(BrewerColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(BrewerColors.textSecondary)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
    }
}

// MARK: - About Row Component
struct AboutRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(BrewerColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(BrewerColors.textSecondary)
        }
    }
}

// MARK: - Data Stat Cell Component
struct DataStatCell: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            SVGIcon(icon, size: 24, color: BrewerColors.caramel.opacity(0.8))
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(BrewerColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

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

#Preview {
    GlobalBackground {
        Settings()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
