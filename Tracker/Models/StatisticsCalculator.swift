import Foundation

final class StatisticsCalculator {

    private let trackers: [Tracker]
    private let records: [TrackerRecord]

    init(trackers: [Tracker], records: [TrackerRecord]) {
        self.trackers = trackers
        self.records = records
    }

    func calculate() -> TrackerStatistics {
        guard !trackers.isEmpty else {
            return TrackerStatistics(bestStreak: 0, idealDays: 0, completedTrackers: 0, averageCompletedPerDay: 0)
        }

        let calendar = Calendar.current
        var recordsByDay: [Date: [TrackerRecord]] = [:]
        
        for record in records {
            let day = calendar.startOfDay(for: record.date)
            recordsByDay[day, default: []].append(record)
        }

        let sortedDays = Array(recordsByDay.keys).sorted()
        var bestStreak = 0
        var currentStreak = 0
        var previousDay: Date? = nil
        
        for day in sortedDays {
            if let prev = previousDay, calendar.dateComponents([.day], from: prev, to: day).day == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            bestStreak = max(bestStreak, currentStreak)
            previousDay = day
        }

        let idealDays = recordsByDay.filter { day, dayRecords in
            let weekdayNumber = calendar.component(.weekday, from: day)
            let adjustedWeekday = weekdayNumber == 1 ? 7 : weekdayNumber - 1
            guard let weekday = Weekday(rawValue: adjustedWeekday) else { return false }
            
            let activeTrackers = trackers.filter { $0.schedule.contains(weekday) }
            
            if activeTrackers.isEmpty {
                return false
            }
            
            let completedTrackerIDs = Set(dayRecords.map { $0.trackerID })
            let activeTrackerIDs = Set(activeTrackers.map { $0.id })
            
            return completedTrackerIDs == activeTrackerIDs
        }.count

        let completedTrackers = records.count
        let averageCompletedPerDay = recordsByDay.isEmpty ? 0 : Double(records.count) / Double(recordsByDay.count)

        return TrackerStatistics(
            bestStreak: bestStreak,
            idealDays: idealDays,
            completedTrackers: completedTrackers,
            averageCompletedPerDay: averageCompletedPerDay
        )
    }
}
