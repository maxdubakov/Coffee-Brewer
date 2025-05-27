import Foundation

// MARK: - Time Formatting Extensions

extension Double {
    /// Formats time in seconds to "m:ss" format
    /// - Returns: Formatted time string (e.g., "2:45")
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Formats time in seconds to "mm:ss" format with zero-padded minutes
    /// - Returns: Formatted time string (e.g., "02:45")
    var formattedTimeWithPaddedMinutes: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension Int {
    /// Formats time in seconds to "m:ss" format
    /// - Returns: Formatted time string (e.g., "2:45")
    var formattedTime: String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Formats time in seconds to "mm:ss" format with zero-padded minutes
    /// - Returns: Formatted time string (e.g., "02:45")
    var formattedTimeWithPaddedMinutes: String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension Int16 {
    /// Formats time in seconds to "m:ss" format
    /// - Returns: Formatted time string (e.g., "2:45")
    var formattedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Time Formatting Functions

/// Formats time in seconds to "m:ss" format
/// - Parameter timeInSeconds: Time value in seconds
/// - Returns: Formatted time string (e.g., "2:45")
func formatTime(_ timeInSeconds: Double) -> String {
    timeInSeconds.formattedTime
}

/// Formats time in seconds to "m:ss" format
/// - Parameter timeInSeconds: Time value in seconds
/// - Returns: Formatted time string (e.g., "2:45")
func formatTime(_ timeInSeconds: Int) -> String {
    timeInSeconds.formattedTime
}