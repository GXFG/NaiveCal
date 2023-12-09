import SwiftUI
import LaunchAtLogin

struct SettingGeneralView: View {
    @StateObject var settings = AppSettings()
    
    private let weekLabelList = [
        WeekLabel(title: NSLocalizedString("settingWeekLabelTitle1", comment: ""), value: 1),
        WeekLabel(title: NSLocalizedString("settingWeekLabelTitle7", comment: ""), value: 7),
    ]

    @State private var isLaunchAtLogin = false
    
    var body: some View {
        VStack {
            HStack {
                Text("settingLaunchAtLogin")
                    .frame(width: 120, alignment: .trailing)
                
                Toggle("", isOn: $isLaunchAtLogin)
                    .toggleStyle(.switch)
                    .onChange(of: isLaunchAtLogin) { newValue in
                        if newValue == self.isLaunchAtLogin {
                            return
                        }
                        LaunchAtLogin.isEnabled = newValue
                    }
            }
            
            HStack {
                Text("settingWeekStartsOn")
                    .frame(width: 160, alignment: .trailing)

                Picker("", selection: settings.$weekBeginsOn) {
                     ForEach(weekLabelList) { weekLabel in
                         Text(weekLabel.title).tag(weekLabel.value)
                     }
                 }
                 .pickerStyle(PopUpButtonPickerStyle())
                 .frame(width: 80)
            }
        }
        .onAppear {
            self.isLaunchAtLogin = LaunchAtLogin.isEnabled
        }
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 100))
        Spacer()
    }
    
}

#Preview {
    SettingGeneralView()
}
