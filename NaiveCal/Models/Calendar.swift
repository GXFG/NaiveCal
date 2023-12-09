import Foundation

struct SettingLabel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
}

struct WeekLabel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: Int // 1234567
}

struct DayItem: Identifiable, Hashable {
    let id = UUID()
    let date: String // YYYY-MM-DD
    let day: Int // D
    let desc: String // 节日
    let type: Int // 0不展示，1休，2班
    let isToday: Bool
    let isWeekend: Bool
    let isFestival: Bool
    let isNotCurrMonth: Bool
}
