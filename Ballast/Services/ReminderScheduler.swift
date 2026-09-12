import Foundation
import UserNotifications

/// Owns all local notification scheduling. Views never call
/// `UNUserNotificationCenter` directly — go through this object.
///
/// Reminders are deliberately gentle: no shaming copy, no "you're about to
/// lose it" urgency. One optional daily nudge per habit, nothing more.
@Observable
final class ReminderScheduler {

    static let shared = ReminderScheduler()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    /// Requests permission only if the user hasn't already been asked.
    /// Returns whether reminders can actually be scheduled right now.
    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    /// Schedules a daily reminder for a habit, replacing any existing one.
    /// Pass `nil` as the habit's `reminderTime` beforehand to cancel instead.
    func scheduleReminder(for habit: Habit) {
        let identifier = identifier(for: habit)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard let time = habit.reminderTime else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(habit.emoji) \(habit.name)"
        content.body = "A quiet nudge — no pressure if today's not the day."
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelReminder(for habit: Habit) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: habit)])
    }

    private func identifier(for habit: Habit) -> String {
        "ballast-habit-\(habit.id.uuidString)"
    }
}
