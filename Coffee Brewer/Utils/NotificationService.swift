import Foundation
import UserNotifications

// MARK: - Notification Service

enum NotificationService {
  /// Requests local notification permission (alert + sound). Fire-and-forget.
  static func requestPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
  }

  /// Schedules a brew-rating reminder 1 hour after saving a brew.
  static func scheduleBrewRatingReminder(brewID: UUID) {
    let content = UNMutableNotificationContent()
    content.title = "How was your brew?"
    content.body = "Tap to rate your latest brew"
    content.sound = .default
    content.userInfo = ["brewID": brewID.uuidString]

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
    let identifier = "brew-rating-\(brewID.uuidString)"
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
      if let error {
        print("NotificationService: failed to schedule reminder: \(error)")
      }
    }
  }

  /// Cancels a pending brew-rating reminder (e.g. if brew is deleted or already rated).
  static func cancelBrewRatingReminder(brewID: UUID) {
    let identifier = "brew-rating-\(brewID.uuidString)"
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
  }
}

// MARK: - Notification Names

extension Notification.Name {
  /// Posted (via NotificationCenter) when a brew-rating notification is tapped.
  /// userInfo key "brewID" contains the brew's UUID.
  static let openRatingSheet = Notification.Name("openRatingSheet")
}
