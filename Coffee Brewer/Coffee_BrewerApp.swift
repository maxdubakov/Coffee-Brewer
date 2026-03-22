import SwiftUI
import UserNotifications

// MARK: - Notification Delegate

/// Handles UNUserNotificationCenter callbacks and bridges taps into the app via NotificationCenter.
final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    /// Show banner + play sound even when the app is foregrounded.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// User tapped a notification — extract the brewID and broadcast via NotificationCenter.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let brewIDString = userInfo["brewID"] as? String,
           let brewID = UUID(uuidString: brewIDString) {
            NotificationCenter.default.post(
                name: .openRatingSheet,
                object: nil,
                userInfo: ["brewID": brewID]
            )
        }
        completionHandler()
    }
}

// MARK: - App

@main
struct Coffee_BrewerApp: App {
    let persistenceController: PersistenceController
    /// Retained for the app's lifetime — UNUserNotificationCenter holds it weakly.
    private let notificationDelegate: AppNotificationDelegate

    init() {
        let persistence = PersistenceController.shared
        let delegate = AppNotificationDelegate()
        self.persistenceController = persistence
        self.notificationDelegate = delegate
        UNUserNotificationCenter.current().delegate = delegate
        NotificationService.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            GlobalBackground {
                Main()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
