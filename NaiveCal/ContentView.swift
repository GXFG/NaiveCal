import SwiftUI
import LunarSwift

struct ContentView: View {
    @StateObject var settings = AppSettings()
    
    private var calendar = Calendar.current
    private let sundayOption = WeekLabel(title: NSLocalizedString("WeekLabelTitle7", comment: ""), value: 7)
    private let weekLabelList = [
        WeekLabel(title: NSLocalizedString("WeekLabelTitle1", comment: ""), value: 1),
        WeekLabel(title: NSLocalizedString("WeekLabelTitle2", comment: ""), value: 2),
        WeekLabel(title: NSLocalizedString("WeekLabelTitle3", comment: ""), value: 3),
        WeekLabel(title: NSLocalizedString("WeekLabelTitle4", comment: ""), value: 4),
        WeekLabel(title: NSLocalizedString("WeekLabelTitle5", comment: ""), value: 5),
        WeekLabel(title: NSLocalizedString("WeekLabelTitle6", comment: ""), value: 6),
        WeekLabel(title: NSLocalizedString("WeekLabelTitle7", comment: ""), value: 7),
    ]
    
    @State private var currYear = 0
    @State private var currMonth = 0
    @State private var currDay = 0
    @State private var dateList: [DayItem] = []
    @State private var dateLayoutList: [[DayItem]] = []
    
    @State private var todayYmd = ""
    @State private var trueYear = 0
    @State private var trueMonth = 0
    
    @State private var isNewVersion = false
    @State private var hoveredDayItem: DayItem? = nil
    
    var computedweekList: [WeekLabel] {
        var resList = self.weekLabelList
        if (self.settings.weekBeginsOn == 7) {
            resList.removeLast()
            resList.insert(self.sundayOption, at: 0)
        }
        return resList
    }
    
    struct DateFormatterSingleton {
        static let sharedYMD: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "UTC")
            return formatter
        }()
        
        static let sharedDay: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            formatter.timeZone = TimeZone(identifier: "UTC")
            return formatter
        }()
    }
    
    init() {
        self.calendar.timeZone = TimeZone(identifier: "UTC")!
        self.calendar.firstWeekday = 2 // 设置星期一为一周的第一天
    }
    
    func setCurrData() {
        let nowDate = Date()
        let datecomponents = calendar.dateComponents([.year, .month, .day], from: nowDate)
        self.currYear = datecomponents.year ?? 0
        self.currMonth = datecomponents.month ?? 0
        self.currDay = datecomponents.day ?? 0
        self.todayYmd = DateFormatterSingleton.sharedYMD.string(from: nowDate)
        self.trueYear = self.currYear
        self.trueMonth = self.currMonth
    }
    
    func getAdjustedWeekday(weekday: Int) -> Int {
        // 由于设置了星期一为一周的第一天，需要调整得到的weekday值
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
        return adjustedWeekday
    }
    
    func handleDate(ymdStr: String, num: Int,byAdding: Calendar.Component = .day) -> (
        date: Date,
        ymdStr: String,
        day: Int,
        week: Int
    ) {
        guard let inputDate = DateFormatterSingleton.sharedYMD.date(from: ymdStr) else {
            fatalError("Invalid date string: \(ymdStr)")
        }
        var dateComponents = DateComponents()
        dateComponents.setValue(num, for: byAdding)
        guard let modifiedDate = calendar.date(byAdding: dateComponents, to: inputDate) else {
            fatalError("Date calculation error")
        }
        let day = calendar.component(.day, from: modifiedDate)
        let weekday = calendar.component(.weekday, from: modifiedDate)
        let adjustedWeekday = getAdjustedWeekday(weekday: weekday)
        let resYmdStr = DateFormatterSingleton.sharedYMD.string(from: modifiedDate)
        
        return (
            date: modifiedDate,
            ymdStr: resYmdStr,
            day: day,
            week: adjustedWeekday
        )
    }
    
    func genDateList(type: String, dateEle: Date) {
        let formatDate = DateFormatterSingleton.sharedYMD.string(from: dateEle)
        let targetDateEle = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: dateEle)!
        let week = calendar.component(.weekday, from: targetDateEle)
        let solarEle = Solar.fromDate(date: targetDateEle)
        let lunarEle = Lunar.fromDate(date: targetDateEle)
        let holidayEle = HolidayUtil.getHoliday(ymd: formatDate)
        var desc = solarEle.festivals.first ?? lunarEle.festivals.first ?? lunarEle.jieQi
        var isFestival = true
        if desc.isEmpty {
            isFestival = false
            desc = lunarEle.day == 1 ? "\(lunarEle.monthInChinese)月" : lunarEle.dayInChinese
        }
        
        var dayType = 0
        if (holidayEle != nil) {
            if ((holidayEle?.work) == true) {
                dayType = 2
            } else if ((holidayEle?.name) != nil) {
                dayType = 1
            }
        }
        
        let param = DayItem(
            date: formatDate,
            day: solarEle.day,
            desc: desc, // 节日
            type: dayType, // 0不展示，1休，2班
            isToday: self.todayYmd == formatDate,
            isWeekend: [1, 7].contains(week),
            isFestival: isFestival,
            isNotCurrMonth: type != "main"
        )
        
        if type == "start" {
            self.dateList.insert(param, at: 0)
        } else {
            self.dateList.append(param)
        }
    }
    
    func onRender() {
        self.dateList = []
        let currMonthFirstDate = "\(self.currYear)-\(self.currMonth)-01"
        var currMonthFirstDateWeek = calendar.component(.weekday, from: DateFormatterSingleton.sharedYMD.date(from: currMonthFirstDate)!)
        currMonthFirstDateWeek = getAdjustedWeekday(weekday: currMonthFirstDateWeek)
        
        //padStart
        var padStartCount = currMonthFirstDateWeek - 1
        // begins on sunday
        if self.settings.weekBeginsOn == 7 {
            padStartCount = currMonthFirstDateWeek == 7 ? 0 : currMonthFirstDateWeek
        }
        for index in 0..<padStartCount {
            let dateEle = self.handleDate(ymdStr: currMonthFirstDate, num: -(index + 1)).date
            genDateList(type: "start", dateEle: dateEle)
        }
        
        let currNextMonthFirstDate = self.handleDate(ymdStr: currMonthFirstDate, num: 1, byAdding: .month).ymdStr
        let currMonthLastDateCustomEle = self.handleDate(ymdStr: currNextMonthFirstDate, num: -1, byAdding: .day)
        let currMonthLastDay = currMonthLastDateCustomEle.day
        let currMonthLastDateWeek = currMonthLastDateCustomEle.week
        
        // add main
        for index in -1..<currMonthLastDay - 1 {
            let dateEle = self.handleDate(ymdStr: currMonthFirstDate, num: index + 1).date
            genDateList(type: "main", dateEle: dateEle)
        }
        
        // padEnd
        var padEndCount = 7 - currMonthLastDateWeek
        if (self.settings.weekBeginsOn == 7) {
            // begins on sunday
            padEndCount = currMonthLastDateWeek == 7 ? 6 : 6 - currMonthLastDateWeek
        }
        if (self.dateList.count + padEndCount == 35) {
            // 确保整体为6行
            padEndCount += 7
        }
        
        for index in 0..<padEndCount {
            let dateEle = self.handleDate(ymdStr: currMonthLastDateCustomEle.ymdStr, num: index + 1).date
            genDateList(type: "end", dateEle: dateEle)
        }
        
        self.dateLayoutList = []
        var rowList: [DayItem] = []
        for (index, item) in dateList.enumerated() {
            rowList.append(item)
            if((index + 1) % 7 == 0) {
                self.dateLayoutList.append(rowList)
                rowList = []
            }
        }
    }
    
    func onPrevMonth() {
        if self.currMonth == 1 {
            self.currYear -= 1
            self.currMonth = 12
        } else {
            self.currMonth -= 1
        }
        self.onRender()
    }
    
    func onNextMonth() {
        if self.currMonth == 12 {
            self.currYear += 1
            self.currMonth = 1
        } else {
            self.currMonth += 1
        }
        self.onRender()
    }
    
    func onReset() {
        let currDateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        self.currYear = currDateComponents.year ?? 0
        self.currMonth = currDateComponents.month ?? 0
        self.currDay = currDateComponents.day ?? 0
        self.onRender()
    }
    
    func getItemTagTextContent(dayItem: DayItem) -> String {
        var text = ""
        if dayItem.type == 1 {
            text = NSLocalizedString("DayItemRestTag", comment: "")
        } else if dayItem.type == 2 {
            text = NSLocalizedString("DayItemWorkTag", comment: "")
        }
        return text
    }
    
    func getItemColor(dayItem: DayItem) -> Color {
        var color = Color.clear
        if dayItem.type == 1 {
            color = Color("DayItemRestColor")
        } else if dayItem.type == 2 {
            color = Color("DayItemWorkColor")
        } else if dayItem.isToday {
            color = Color("DayItemTodayColor")
        }
        return color
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                HStack {
                    if (self.isNewVersion) {
                        Link("newVersion", destination: URL(string: "https://github.com/GXFG/naivecal-macOS/releases")!)
                    }
                }
                .frame(width: 50)
                .padding(.trailing, 3)
                
                HStack {
                    Button(action: self.onPrevMonth) {
                        Image(systemName: "chevron.left")
                    }
                    
                    HStack(spacing: 0) {
                        Text("\(String(format: "%d", self.currYear))")
                        Text("-")
                            .padding([.leading, .trailing], 3)
                        Text(String(format: "%02d", self.currMonth))
                    }
                    .font(.system(size: 16))
                    .monospacedDigit()
                    
                    Button(action: self.onNextMonth) {
                        Image(systemName: "chevron.right")
                    }
                }
                
                HStack {
                    if (self.trueYear != self.currYear || self.trueMonth != self.currMonth) {
                        Button(action: self.onReset) {
                            Image(systemName: "arrowshape.turn.up.backward")
                        }
                    }
                }
                .frame(width: 50)
            }
            
            HStack(spacing: 0) {
                ForEach(computedweekList) { weekLabel in
                    Text(weekLabel.title)
                        .frame(width: 45, height: 20)
                        .font(.system(size: 14).weight(.bold))
                        .foregroundColor((weekLabel.value == 6 || weekLabel.value == 7) ? .red : nil)
                }
            }
            
            VStack(spacing: 0) {
                ForEach(dateLayoutList, id: \.self) { rowItem in
                    HStack(spacing: 0) {
                        ForEach(rowItem) { dayItem in
                            ZStack(alignment: .topTrailing) {
                                VStack(spacing: 0) {
                                    Text(" \(dayItem.day) ")
                                        .font(.title2)
                                        .foregroundColor(dayItem.isWeekend ? .red : nil)
                                        .shadow(color: hoveredDayItem == dayItem ? .gray : .clear, radius: hoveredDayItem == dayItem ? 7 : 0)
                                    if (settings.isLunarVisible) {
                                        Text(String(localized: "\(dayItem.desc)"))
                                            .font(.caption)
                                            .foregroundColor(dayItem.isFestival ? .red : nil)
                                            .shadow(color: hoveredDayItem == dayItem ? .gray : .clear, radius: hoveredDayItem == dayItem ? 7 : 0)
                                    }
                                }
                                .frame(width: 45, height: 45)
                                .opacity(dayItem.isNotCurrMonth ? 0.3 : 1)
                                .background(getItemColor(dayItem: dayItem))
                                .cornerRadius(dayItem.isToday ? 4 : 0)
                                .onHover { hovering in
                                    self.hoveredDayItem = hovering ? dayItem : nil
                                }
                                
                                Text(getItemTagTextContent(dayItem: dayItem))
                                    .padding([.top, .trailing], 1)
                                    .font(.system(size: 10))
                                    .foregroundColor(dayItem.type == 2 ? .red : nil)
                            }
                        }
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .onAppear{
            self.setCurrData()
            self.onRender()
        }
    }
}

#Preview {
    ContentView()
}
