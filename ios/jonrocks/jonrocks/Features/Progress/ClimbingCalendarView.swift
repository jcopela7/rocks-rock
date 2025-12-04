import SwiftUI

struct ClimbingCalendarView: View {
    let month: Date
    let ascents: [AscentDTO]

    private var calendar: Calendar {
        Calendar.current
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }

    private var firstDayOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: month)
        return calendar.date(from: components) ?? month
    }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: month)?.count ?? 0
    }

    private var firstWeekday: Int {
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Convert from 1-7 (Sunday-Saturday) to 0-6 (Sunday-Saturday)
        return (weekday + 6) % 7
    }

    private var climbingDates: Set<String> {
        Set(ascents.map { ascent in
            let components = calendar.dateComponents([.year, .month, .day], from: ascent.climbedAt)
            return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
        })
    }

    private var dayHeaders: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }

    private var weekStreak: Int {
        guard !ascents.isEmpty else { return 0 }

        // Get all unique weeks with climbs (using yearForWeekOfYear and weekOfYear)
        let weeksWithClimbs = Set(ascents.map { ascent in
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: ascent.climbedAt)
            let year = components.yearForWeekOfYear ?? 0
            let week = components.weekOfYear ?? 0
            return "\(year)-\(week)"
        })

        // Convert to sortable dates (start of each week - Sunday)
        let weekDates = weeksWithClimbs.compactMap { weekKey -> Date? in
            let parts = weekKey.split(separator: "-")
            guard parts.count == 2,
                  let year = Int(parts[0]),
                  let week = Int(parts[1]) else { return nil }
            var components = DateComponents()
            components.yearForWeekOfYear = year
            components.weekOfYear = week
            components.weekday = 1 // Sunday (matching calendar display)
            return calendar.date(from: components)
        }.sorted()

        guard !weekDates.isEmpty else { return 0 }

        // Calculate longest consecutive streak
        var longestStreak = 1
        var currentStreak = 1

        for i in 1 ..< weekDates.count {
            // Check if this week is exactly 1 week after the previous week
            if let expectedPreviousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: weekDates[i]),
               calendar.isDate(expectedPreviousWeek, equalTo: weekDates[i - 1], toGranularity: .weekOfYear)
            {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }

        return longestStreak
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month and year header
            Text(monthYearString)
                .font(.headline)
                .foregroundColor(Color.theme.accent)
                .padding(.top, 16)

            // Week streak metric
            HStack(alignment: .center, spacing: 32) {
                weekStreakMetric(label: "Week Streak", value: "\(weekStreak)")
            }

            // Day name headers
            HStack(spacing: 0) {
                ForEach(dayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundStyle(Color.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                // Empty cells for days before the first day of the month
                ForEach(0 ..< firstWeekday, id: \.self) { _ in
                    Color.clear
                        .frame(height: 40)
                }

                // Days of the month
                ForEach(1 ... daysInMonth, id: \.self) { day in
                    let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) ?? firstDayOfMonth
                    let dayComponents = calendar.dateComponents([.year, .month, .day], from: dayDate)
                    let dateString = "\(dayComponents.year ?? 0)-\(dayComponents.month ?? 0)-\(dayComponents.day ?? 0)"
                    let hasClimb = climbingDates.contains(dateString)

                    DayCell(day: day, hasClimb: hasClimb)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(.white)
    }

    private func weekStreakMetric(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .foregroundStyle(Color.theme.textPrimary)
        }
    }
}

struct DayCell: View {
    let day: Int
    let hasClimb: Bool

    var body: some View {
        ZStack {
            if hasClimb {
                Circle()
                    .stroke(Color.theme.accent, lineWidth: 2)
                    .frame(width: 36, height: 36)
            }

            Text("\(day)")
                .font(.system(size: 14, weight: hasClimb ? .semibold : .regular))
                .foregroundColor(hasClimb ? Color.theme.accent : Color.theme.textPrimary)
        }
        .frame(height: 40)
    }
}
