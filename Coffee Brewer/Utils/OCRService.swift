import Vision
import CoreGraphics

// MARK: - OCR Service

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
