import SwiftUI
import UniformTypeIdentifiers

struct DataManagement: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var dataManager: DataManager
    
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var exportData: Data?
    @State private var exportFileName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _dataManager = StateObject(wrappedValue: DataManager(viewContext: context))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Data Management")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(BrewerColors.textPrimary)
            
            VStack(spacing: 0) {
                // Export Data
                SettingsRow(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Save \(dataManager.getTotalDataSize()) items",
                    action: handleExport,
                    showDivider: true
                )
                
                // Import Data
                SettingsRow(
                    icon: "square.and.arrow.down",
                    title: "Import Data",
                    subtitle: "Restore from backup",
                    action: { showingImportPicker = true },
                    showDivider: false
                )
            }
            .background(BrewerColors.cardBackground.opacity(0.5))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                BrewerColors.divider.opacity(0.3),
                                BrewerColors.divider.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
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
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleExport() {
        Task { @MainActor in
            do {
                let (data, fileName) = try await dataManager.exportData()
                exportData = data
                exportFileName = fileName
                showingExportSheet = true
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            Task {
                do {
                    try await dataManager.importData(from: url)
                } catch {
                    await MainActor.run {
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            }
        case .failure(let error):
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}
