import Foundation
import CoreData

struct TemporalAxis: ChartAxis {
    let type: TemporalAxisType
    
    var id: String { type.rawValue }
    var displayName: String { type.displayName }
    var axisType: AxisType { .temporal }
    
    func extractValue(from brew: Brew) -> Any? {
        guard let brewDate = brew.date else { return nil }
        
        let date: Date = switch type {
        case .brewDate:
            brewDate
        case .brewWeek:
            startOfWeek(for: brewDate)
        case .brewMonth:
            startOfMonth(for: brewDate)
        case .dayOfWeek:
            brewDate // We'll use the date but display as day name
        case .timeOfDay:
            brewDate // We'll use the date but display as hour
        }
        
        return TemporalAxisValue(date: date)
    }
    
    private func startOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private func startOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
    
    func dateRange(for brews: [Brew]) -> ClosedRange<Date>? {
        let dates = brews.compactMap { extractValue(from: $0) as? TemporalAxisValue }
            .map { $0.date }
        
        guard !dates.isEmpty else { return nil }
        
        let minDate = dates.min() ?? Date()
        let maxDate = dates.max() ?? Date()
        
        return minDate...maxDate
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        switch type {
        case .brewDate:
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        case .brewWeek:
            formatter.dateFormat = "MMM d"
        case .brewMonth:
            formatter.dateFormat = "MMM yyyy"
        case .dayOfWeek:
            formatter.dateFormat = "EEEE"
        case .timeOfDay:
            formatter.dateFormat = "ha"
        }
        
        return formatter.string(from: date)
    }
    
    func groupValue(for date: Date) -> String {
        switch type {
        case .dayOfWeek:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        case .timeOfDay:
            let hour = Calendar.current.component(.hour, from: date)
            switch hour {
            case 0..<6: return "Night"
            case 6..<12: return "Morning"
            case 12..<17: return "Afternoon"
            case 17..<22: return "Evening"
            default: return "Night"
            }
        default:
            return formatDate(date)
        }
    }
    
    // Helper for grouping brews by time period
    func groupBrews(_ brews: [Brew]) -> [(date: Date, label: String, count: Int)] {
        let calendar = Calendar.current
        var groups: [Date: [Brew]] = [:]
        
        for brew in brews {
            guard let value = extractValue(from: brew) as? TemporalAxisValue else { continue }
            
            let groupDate: Date = switch type {
            case .brewDate:
                // For daily view, use the exact date
                calendar.startOfDay(for: value.date)
            case .brewWeek:
                startOfWeek(for: value.date)
            case .brewMonth:
                startOfMonth(for: value.date)
            case .dayOfWeek, .timeOfDay:
                value.date // These will be grouped by the groupValue method
            }
            
            groups[groupDate, default: []].append(brew)
        }
        
        return groups.map { (date: $0.key, label: formatDate($0.key), count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }
}

extension TemporalAxis {
    static var allAxes: [TemporalAxis] {
        TemporalAxisType.allCases.map { TemporalAxis(type: $0) }
    }
}