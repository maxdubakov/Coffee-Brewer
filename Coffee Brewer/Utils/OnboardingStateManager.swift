import Foundation

class OnboardingStateManager: ObservableObject {
    static let shared = OnboardingStateManager()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let hasCompletedWelcome = "hasCompletedWelcome"
        static let hasCreatedFirstRecipe = "hasCreatedFirstRecipe"
        static let hasCompletedFirstBrew = "hasCompletedFirstBrew"
        static let hasSeenLibraryIntro = "hasSeenLibraryIntro"
        static let hasSeenRecordingDemo = "hasSeenRecordingDemo"
        static let onboardingDismissedAt = "onboardingDismissedAt"
        static let onboardingVersion = "onboardingVersion"
    }
    
    @Published var hasCompletedWelcome: Bool {
        didSet {
            userDefaults.set(hasCompletedWelcome, forKey: Keys.hasCompletedWelcome)
        }
    }
    
    @Published var hasCreatedFirstRecipe: Bool {
        didSet {
            userDefaults.set(hasCreatedFirstRecipe, forKey: Keys.hasCreatedFirstRecipe)
        }
    }
    
    @Published var hasCompletedFirstBrew: Bool {
        didSet {
            userDefaults.set(hasCompletedFirstBrew, forKey: Keys.hasCompletedFirstBrew)
        }
    }
    
    @Published var hasSeenLibraryIntro: Bool {
        didSet {
            userDefaults.set(hasSeenLibraryIntro, forKey: Keys.hasSeenLibraryIntro)
        }
    }
    
    @Published var hasSeenRecordingDemo: Bool {
        didSet {
            userDefaults.set(hasSeenRecordingDemo, forKey: Keys.hasSeenRecordingDemo)
        }
    }
    
    var onboardingDismissedAt: Date? {
        get { userDefaults.object(forKey: Keys.onboardingDismissedAt) as? Date }
        set { userDefaults.set(newValue, forKey: Keys.onboardingDismissedAt) }
    }
    
    var onboardingVersion: String {
        get { userDefaults.string(forKey: Keys.onboardingVersion) ?? "1.0" }
        set { userDefaults.set(newValue, forKey: Keys.onboardingVersion) }
    }
    
    private init() {
        hasCompletedWelcome = userDefaults.bool(forKey: Keys.hasCompletedWelcome)
        hasCreatedFirstRecipe = userDefaults.bool(forKey: Keys.hasCreatedFirstRecipe)
        hasCompletedFirstBrew = userDefaults.bool(forKey: Keys.hasCompletedFirstBrew)
        hasSeenLibraryIntro = userDefaults.bool(forKey: Keys.hasSeenLibraryIntro)
        hasSeenRecordingDemo = userDefaults.bool(forKey: Keys.hasSeenRecordingDemo)
    }
    
    func dismissOnboarding() {
        hasCompletedWelcome = true
        onboardingDismissedAt = Date()
    }
    
    func resetOnboarding() {
        hasCompletedWelcome = false
        hasCreatedFirstRecipe = false
        hasCompletedFirstBrew = false
        hasSeenLibraryIntro = false
        hasSeenRecordingDemo = false
        onboardingDismissedAt = nil
        onboardingVersion = "1.0"
    }
}