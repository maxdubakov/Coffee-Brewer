# Task 001 — OCR Sandbox Tab (Raw Text Extraction)

## Objective

Add a 4th "Scan" tab to the app. The tab lets the user pick a photo from the library or take one with the camera, runs on-device OCR, and displays the raw recognized text. This is Iteration 1 — no matching/extraction logic, just prove out the pipeline.

## iOS Target

The project targets **iOS 18.0**. Use the **new Swift Vision API** (WWDC24), NOT the legacy VNRecognizeTextRequest.

## Files to Create

### 1. `Coffee Brewer/Coffee Brewer/Utils/OCRService.swift`

A stateless enum (matches `NotificationService.swift` style) with a single static async method.

```swift
import Vision
import CoreGraphics

enum OCRService {
  /// Recognizes text from a CGImage using the iOS 18 Vision API.
  static func recognizeText(from image: CGImage) async throws -> [String] {
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    let observations = try await request.perform(on: image)
    return observations.compactMap { $0.topCandidates(1).first?.string }
  }
}
```

Key points:
- `import Vision` — the new framework (no VN prefix types)
- `RecognizeTextRequest()` — NOT `VNRecognizeTextRequest`
- `request.perform(on: image)` returns observations directly — no handler, no callback
- Pure async/await, standard Swift throws

### 2. `Coffee Brewer/Coffee Brewer/Views/Components/CameraPickerRepresentable.swift`

Minimal `UIViewControllerRepresentable` wrapping `UIImagePickerController` with `.sourceType = .camera`.

```swift
import SwiftUI

struct CameraPickerRepresentable: UIViewControllerRepresentable {
  @Binding var image: UIImage?
  @Environment(\.dismiss) private var dismiss

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

  func makeCoordinator() -> Coordinator { Coordinator(self) }

  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: CameraPickerRepresentable
    init(_ parent: CameraPickerRepresentable) { self.parent = parent }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      parent.image = info[.originalImage] as? UIImage
      parent.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.dismiss()
    }
  }
}
```

### 3. `Coffee Brewer/Coffee Brewer/Views/Scan/ScanView.swift`

The main view for the Scan tab. UI structure:

```
VStack:
  PageTitleH1("Scan")          // reuse existing component

  // Action buttons row
  HStack:
    PhotosPicker button (from PhotosUI) — "Choose Photo"
    Camera button — "Take Photo"

  // Results area
  if isProcessing:
    ProgressView()
  else if recognizedLines is not empty:
    ScrollView with all recognized lines
  else:
    placeholder text "Take or choose a photo of a coffee bag to scan"
```

State:
- `@State private var selectedPhotoItem: PhotosPickerItem?`
- `@State private var capturedImage: UIImage?`
- `@State private var recognizedLines: [String] = []`
- `@State private var isProcessing: Bool = false`
- `@State private var showCamera: Bool = false`
- `@State private var errorMessage: String?`

Behavior:
- When `selectedPhotoItem` changes (`.onChange`), load the image data, convert to `CGImage`, call `OCRService.recognizeText(from:)` in a `Task { }`, update `recognizedLines`
- When `capturedImage` changes, same flow — convert `UIImage` → `CGImage`, call OCR
- Show `isProcessing = true` while OCR runs, set to `false` when done
- Catch errors and show `errorMessage`
- Display results in a `ScrollView` with each line as a `Text` view, using `BrewerColors.textPrimary` on `BrewerColors.background`

Style guide (match existing app):
- Background: `BrewerColors.background`
- Text: `BrewerColors.textPrimary` for results, `BrewerColors.textSecondary` for placeholder
- Buttons: match the style used elsewhere — `BrewerColors.cream` foreground, coffee-toned backgrounds
- Use `PageTitleH1` for the title
- Use 2-space indentation (matches `NotificationService.swift`)

### 4. Modify `Coffee Brewer/Coffee Brewer/Views/Main.swift`

Add a 4th tab after the History tab (before the closing of TabView):

```swift
// Scan tab
NavigationStack {
    ScanView()
        .background(BrewerColors.background)
}
.tabItem {
    Image(systemName: "text.viewfinder")
}
.tag(Tab.scan)
```

Also update the `Tab` enum to include `scan`:
```swift
enum Tab {
    case brew, add, history, scan
}
```

## Privacy Descriptions

The project has NO Info.plist file — it uses Xcode auto-generated settings. You need to add an Info.plist file at `Coffee Brewer/Coffee Brewer/Info.plist` with these keys:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>Used to scan coffee bag labels</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Used to select coffee bag photos for scanning</string>
</dict>
</plist>
```

## What NOT to do

- Do NOT add any field matching/extraction logic — this is raw OCR only
- Do NOT persist scan results
- Do NOT use the old `VNRecognizeTextRequest` / `VNImageRequestHandler` API
- Do NOT add any Core Data dependencies to the Scan tab

## Verification

After implementation, the app should:
1. Build without errors targeting iOS 18.0
2. Show 4 tabs: Brew, Add, History, Scan
3. Scan tab shows title + two buttons (Choose Photo / Take Photo)
4. Selecting/taking a photo runs OCR and displays recognized text lines
5. Loading state shown while OCR processes

## Reference Files

- Style reference: `Coffee Brewer/Coffee Brewer/Utils/NotificationService.swift` (enum with static methods, 2-space indent)
- Colors: `Coffee Brewer/Coffee Brewer/Utils/BrewerColors.swift`
- Tab setup: `Coffee Brewer/Coffee Brewer/Views/Main.swift`
- Existing component: `Coffee Brewer/Coffee Brewer/Views/Components/` (for PageTitleH1 etc.)

## Project Root

`/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer`

Source files live under: `Coffee Brewer/Coffee Brewer/` (nested structure)
