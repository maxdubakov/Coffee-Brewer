import SwiftUI
import PhotosUI

struct ScanView: View {
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var recognizedLines: [String] = []
    @State private var isProcessing: Bool = false
    @State private var showCamera: Bool = false
    @State private var errorMessage: String?
    @State private var currentOCRTask: Task<Void, Never>?

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        ZStack {
            BrewerColors.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                PageTitleH1("Scan")

                // Action buttons row
                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(BrewerColors.cream)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(BrewerColors.espresso)
                            .cornerRadius(10)
                    }

                    Button {
                        capturedImage = nil
                        showCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(isCameraAvailable ? BrewerColors.cream : BrewerColors.cream.opacity(0.3))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isCameraAvailable ? BrewerColors.espresso : BrewerColors.espresso.opacity(0.5))
                            .cornerRadius(10)
                    }
                    .disabled(!isCameraAvailable)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                // Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }

                // Results area
                if isProcessing {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: BrewerColors.cream))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if !recognizedLines.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(recognizedLines, id: \.self) { line in
                                Text(line)
                                    .font(.system(size: 15))
                                    .foregroundColor(BrewerColors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(16)
                    }
                } else {
                    Spacer()
                    Text("Take or choose a photo of a coffee bag to scan")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
        // Camera sheet — OCR triggered on dismiss once capturedImage is set
        .sheet(isPresented: $showCamera, onDismiss: {
            if let image = capturedImage {
                startOCR { await runOCR(from: image) }
            }
        }) {
            CameraPickerRepresentable(image: $capturedImage)
                .ignoresSafeArea()
        }
        // Photos picker — OCR triggered when a new item is selected
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            startOCR { await runOCR(from: newItem) }
        }
    }

    // MARK: - OCR Helpers

    /// Cancels any in-flight OCR task and starts a new one.
    private func startOCR(_ work: @escaping () async -> Void) {
        currentOCRTask?.cancel()
        currentOCRTask = Task { await work() }
    }

    private func runOCR(from item: PhotosPickerItem) async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data),
                  let cgImage = uiImage.cgImage else {
                errorMessage = "Could not load image."
                return
            }
            guard !Task.isCancelled else { return }
            recognizedLines = try await OCRService.recognizeText(from: cgImage)
        } catch {
            if !Task.isCancelled {
                errorMessage = "OCR failed: \(error.localizedDescription)"
            }
        }
    }

    private func runOCR(from uiImage: UIImage) async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }
        do {
            guard let cgImage = uiImage.cgImage else {
                errorMessage = "Could not process image."
                return
            }
            guard !Task.isCancelled else { return }
            recognizedLines = try await OCRService.recognizeText(from: cgImage)
        } catch {
            if !Task.isCancelled {
                errorMessage = "OCR failed: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    ScanView()
}
