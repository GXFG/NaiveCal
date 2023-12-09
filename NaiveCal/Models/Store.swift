import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("settingWeekBeginsOn") public var weekBeginsOn = 1
    @AppStorage("settingIsLunarVisible") public var isLunarVisible = true
}
