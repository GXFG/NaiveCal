import SwiftUI
import LunarSwift

let nowDate = Date()
var calendar = Calendar.current

func handleDate(ymdStr: String, num: Int,byAdding: Calendar.Component = .day) -> (
    date: Date,
    ymdStr: String,
    day: Int,
    week: Int
) {
    let dateFormatterYMD = DateFormatter()
    dateFormatterYMD.dateFormat = "yyyy-MM-dd"
    dateFormatterYMD.timeZone = TimeZone(identifier: "UTC")
    let dateFormatterDay = DateFormatter()
    dateFormatterDay.dateFormat = "d"
    dateFormatterDay.timeZone = TimeZone(identifier: "UTC")

    let inputDate = dateFormatterYMD.date(from: ymdStr)
    let modifiedDate = calendar.date(byAdding: byAdding, value: num, to: inputDate!)!
    let resYmdStr = dateFormatterYMD.string(from: modifiedDate)
    let resDayStr = dateFormatterDay.string(from: modifiedDate)
    var day = 0
    if let _day = Int(resDayStr) {
        day = _day
    } else {
        print("Int(resDayStr) error")
    }
    let week = calendar.component(.weekday, from: modifiedDate)  // 1234567
    return (
        date: modifiedDate,
        ymdStr: resYmdStr,
        day: day,
        week: week
    )
}

struct ContentView: View {
    @State var weekBeginsOn = 1 // 1, 7
    @State var weekLabelList = [
        WeekLabel(title: "一", value: 1),
        WeekLabel(title: "二", value: 2),
        WeekLabel(title: "三", value: 3),
        WeekLabel(title: "四", value: 4),
        WeekLabel(title: "五", value: 5),
        WeekLabel(title: "六", value: 6),
        WeekLabel(title: "日", value: 7),
    ]
    @State var todayYmd = ""
    @State var trueYear = 0
    @State var trueMonth = 0
    @State var currYear = calendar.component(.year, from: nowDate)
    @State var currMonth = calendar.component(.month, from: nowDate)
    @State var currDay = calendar.component(.day, from: nowDate)
    @State var dateList: [DayItem] = []
    @State var dateLayoutList: [[DayItem]] = []

    func initView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let today = dateFormatter.string(from: nowDate)
        self.todayYmd = today
        self.trueYear = calendar.component(.year, from: nowDate)
        self.trueMonth = calendar.component(.month, from: nowDate)
        self.onRender()
    }

    func genDateList(type: String, dateEle: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formatDate = dateFormatter.string(from: dateEle)
        let targetDateEle = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: dateEle)!
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
      isNotCurrMonth: type != "main")

    if type == "start" {
      self.dateList.insert(param, at: 0)
    } else {
      self.dateList.append(param)
    }
  }

  func onRender() {
      self.dateList = []
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      dateFormatter.timeZone = TimeZone(identifier: "UTC")
      let currMonthFirstDate = "\(self.currYear)-\(self.currMonth)-01"
      // week: 1234567
      let currMonthFirstDateWeek = calendar.component(.weekday, from: dateFormatter.date(from: currMonthFirstDate)!)

      //padStart
      var padStartCount = currMonthFirstDateWeek - 1
      // begins on sunday
      if self.weekBeginsOn == 7 {
          padStartCount = currMonthFirstDateWeek == 7 ? 0 : currMonthFirstDateWeek
      }
      for index in 0..<padStartCount {
          let dateEle = handleDate(ymdStr: currMonthFirstDate, num: -index).date
          genDateList(type: "start", dateEle: dateEle)
      }

      let currNextMonthFirstDate = handleDate(ymdStr: currMonthFirstDate, num: 1, byAdding: .month).ymdStr
      let currMonthLastDateCustomEle = handleDate(ymdStr: currNextMonthFirstDate, num: -1, byAdding: .day)
      let currMonthLastDay = currMonthLastDateCustomEle.day
      let currMonthLastDateWeek = currMonthLastDateCustomEle.week

      // add main
      for index in 0..<currMonthLastDay {
          let dateEle = handleDate(ymdStr: currMonthFirstDate, num: index + 1).date
          genDateList(type: "main", dateEle: dateEle)
      }

      // padEnd
      var padEndCount = 7 - currMonthLastDateWeek
      if (self.weekBeginsOn == 7) {
        // begins on sunday
        padEndCount = currMonthLastDateWeek == 7 ? 6 : 6 - currMonthLastDateWeek
      }
      if (self.dateList.count + padEndCount == 35) {
        // 确保整体为6行
        padEndCount += 7
      }
      for index in 0..<padEndCount {
          let dateEle = handleDate(ymdStr: currMonthLastDateCustomEle.ymdStr, num: index + 2).date
          genDateList(type: "end", dateEle: dateEle)
      }
      
      self.dateLayoutList = []
      var rowList: [DayItem] = []
      for (index, item) in self.dateList.enumerated() {
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
    self.currYear = calendar.component(.year, from: nowDate)
    self.currMonth = calendar.component(.month, from: nowDate)
    self.currDay = calendar.component(.day, from: nowDate)
    self.onRender()
  }
    
    func getItemColor(dayItem: DayItem) -> Color {
        var color = Color.clear
        if dayItem.type == 1 {
            color = Color(red: 233/255, green: 253/255, blue: 218/255, opacity: 1)
        } else if dayItem.type == 2 {
            color = Color(red: 246/255, green: 223/255, blue: 222/255, opacity: 1)
        } else if dayItem.isToday {
            color = Color(red: 120/255, green: 120/255, blue: 222/255, opacity: 1)
        }
        return color
    }

    var body: some View {
      VStack {
          HStack {
              HStack {
                  Button(action: {
                      NSApplication.shared.terminate(nil)
                  }) {
                      Image(systemName: "power")
                  }
                  .keyboardShortcut("q")

                  Button(action: self.onPrevMonth) {
                      Image(systemName: "chevron.left")
                  }
                  
                  HStack(spacing: 0) {
                      Text("\(String(format: "%d", self.currYear))")
                          .frame(width: 40)
                          .font(.title3)
                      Text("-")
                          .frame(width: 10)
                          .font(.title3)
                      Text("\(Text(String(format: "%02d", self.currMonth)))")
                          .frame(width: 20)
                          .font(.title3)
        
                  }
                  
                  Button(action: self.onNextMonth) {
                      Image(systemName: "chevron.right")
                  }
              }

              if (self.trueYear != self.currYear || self.trueMonth != self.currMonth) {
                  Button(action: self.onReset) {
                      Image(systemName: "arrowshape.turn.up.backward")
                  }
              } else {
                  Spacer()
                      .frame(width: 40)
              }
          }


          HStack(spacing: 0) {
              ForEach(weekLabelList, id: \.value) { weekLabel in
                  Text("\(weekLabel.title)")
                      .frame(width: 45, height: 20)
                      .font(.title3)
                      .foregroundColor((weekLabel.value == 6 || weekLabel.value == 7) ? .red : nil)
              }
          }

          VStack(spacing: 0) {
              ForEach(dateLayoutList, id: \.self ) { rowItem in
                  HStack(spacing: 0) {
                      ForEach(rowItem, id: \.self) { dayItem in
                          VStack {
                              Text("\(dayItem.day)")
                                  .font(.title2)
                                  .foregroundColor(dayItem.isWeekend ? .red : nil)
                              Text("\(dayItem.desc)")
                                  .font(.caption)
                                  .foregroundColor(dayItem.isFestival ? .red : nil)
                          }
                          .frame(width: 45, height: 45)
                          .opacity(dayItem.isNotCurrMonth ? 0.3 : 1)
                          .background(getItemColor(dayItem: dayItem))
                      }
                  }
              }
          }

      }
      .padding()
      .onAppear{
          self.initView()
      }
    }
}

#Preview {
    ContentView()
}
