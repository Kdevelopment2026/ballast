import Foundation

/// Ballast's "your data is yours" proof point — no account needed to get every
/// check-in back out as plain text.
enum CSVExporter {

    static func export(habits: [Habit]) -> String {
        var rows = ["Habit,Date,Completed"]
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        for habit in habits.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            let sortedCheckIns = habit.checkIns.sorted { $0.date < $1.date }
            for checkIn in sortedCheckIns {
                let dateString = formatter.string(from: checkIn.date)
                rows.append("\"\(escaped(habit.name))\",\(dateString),true")
            }
        }
        return rows.joined(separator: "\n")
    }

    static func writeToTemporaryFile(habits: [Habit]) -> URL? {
        let csv = export(habits: habits)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ballast-export-\(Int(Date().timeIntervalSince1970)).csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private static func escaped(_ value: String) -> String {
        value.replacingOccurrences(of: "\"", with: "\"\"")
    }
}
