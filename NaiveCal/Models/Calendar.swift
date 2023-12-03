import Foundation

struct WeekLabel: Hashable {
    var title: String
    var value: Int // 1234567
}

struct DayItem: Hashable {
    var date: String // YYYY-MM-DD
    var day: Int // D
    var desc: String // 节日
    var type: Int // 0不展示，1休，2班
    var isToday: Bool
    var isWeekend: Bool
    var isFestival: Bool
    var isNotCurrMonth: Bool
}
