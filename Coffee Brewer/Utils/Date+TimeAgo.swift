import Foundation

extension Date {
    func timeAgoDescription(to referenceDate: Date = Date()) -> String {
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: self, to: referenceDate)

        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        } else {
            return "Just now"
        }
    }
}
