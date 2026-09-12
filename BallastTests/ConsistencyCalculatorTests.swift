import XCTest
@testable import Ballast

final class ConsistencyCalculatorTests: XCTestCase {

    private let calendar = Calendar(identifier: .gregorian)

    private func date(daysAgo: Int, from reference: Date = Date(timeIntervalSince1970: 1_700_000_000)) -> Date {
        calendar.date(byAdding: .day, value: -daysAgo, to: reference)!
    }

    func testBrandNewHabitWithNoCheckInsIsZero() {
        let reference = date(daysAgo: 0)
        let result = ConsistencyCalculator.consistency(
            checkInDates: [],
            createdAt: reference,
            asOf: reference,
            calendar: calendar
        )
        XCTAssertEqual(result, 0, accuracy: 0.0001)
    }

    func testPerfectDayOneIsOneHundredPercent() {
        let reference = date(daysAgo: 0)
        let result = ConsistencyCalculator.consistency(
            checkInDates: [reference],
            createdAt: reference,
            asOf: reference,
            calendar: calendar
        )
        XCTAssertEqual(result, 1.0, accuracy: 0.0001)
    }

    func testWindowIsCappedAtThirtyDaysForAnOlderHabit() {
        let reference = date(daysAgo: 0)
        let createdAt = date(daysAgo: 200)
        // Completed every day for the last 15 days only.
        let checkIns = (0..<15).map { date(daysAgo: $0, from: reference) }

        let result = ConsistencyCalculator.consistency(
            checkInDates: checkIns,
            createdAt: createdAt,
            asOf: reference,
            calendar: calendar
        )
        // 15 completed / 30-day window = 0.5
        XCTAssertEqual(result, 0.5, accuracy: 0.0001)
    }

    func testYoungHabitUsesItsOwnAgeAsTheWindow() {
        let reference = date(daysAgo: 0)
        let createdAt = date(daysAgo: 9) // habit is 10 days old, inclusive of today
        let checkIns = [date(daysAgo: 0, from: reference), date(daysAgo: 1, from: reference)]

        let result = ConsistencyCalculator.consistency(
            checkInDates: checkIns,
            createdAt: createdAt,
            asOf: reference,
            calendar: calendar
        )
        // 2 completed / 10-day window (habit is only 10 days old) = 0.2
        XCTAssertEqual(result, 0.2, accuracy: 0.0001)
    }

    func testMissingADayDentsRatherThanZeroesTheScore() {
        let reference = date(daysAgo: 0)
        let createdAt = date(daysAgo: 29) // exactly a 30-day-old habit
        // Completed every day except today.
        let checkIns = (1..<30).map { date(daysAgo: $0, from: reference) }

        let result = ConsistencyCalculator.consistency(
            checkInDates: checkIns,
            createdAt: createdAt,
            asOf: reference,
            calendar: calendar
        )
        XCTAssertEqual(result, 29.0 / 30.0, accuracy: 0.0001)
        XCTAssertGreaterThan(result, 0.9, "Missing one day out of thirty should barely move the number.")
    }

    func testLeastConsistentHabitIsSelectedForReflection() {
        let reference = date(daysAgo: 0)
        let steady = Habit(name: "Steady", createdAt: date(daysAgo: 10))
        let struggling = Habit(name: "Struggling", createdAt: date(daysAgo: 10))
        for offset in 0..<10 {
            steady.checkIns.append(CheckIn(date: date(daysAgo: offset, from: reference), habit: steady))
        }
        struggling.checkIns.append(CheckIn(date: date(daysAgo: 9, from: reference), habit: struggling))

        let result = ConsistencyCalculator.leastConsistentHabit(
            among: [steady, struggling],
            asOf: reference,
            calendar: calendar
        )
        XCTAssertEqual(result?.name, "Struggling")
    }

    func testDuplicateAndOutOfWindowCheckInsAreIgnored() {
        let reference = date(daysAgo: 0)
        let createdAt = date(daysAgo: 29)
        // Today logged twice, one entry outside the 30-day window, one in the future.
        let checkIns = [
            date(daysAgo: 0, from: reference),
            date(daysAgo: 0, from: reference),
            date(daysAgo: 40, from: reference),
            date(daysAgo: -1, from: reference),
        ]

        let result = ConsistencyCalculator.consistency(
            checkInDates: checkIns,
            createdAt: createdAt,
            asOf: reference,
            calendar: calendar
        )
        XCTAssertEqual(result, 1.0 / 30.0, accuracy: 0.0001)
    }
}
