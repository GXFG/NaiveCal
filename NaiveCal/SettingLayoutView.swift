import SwiftUI
import LaunchAtLogin

struct SettingLayoutView: View {
    @StateObject var settings = AppSettings()
    
    var body: some View {
        VStack {
            HStack {
                Text("settingIsLunarVisible")
                    .frame(width: 120, alignment: .trailing)
                
                Toggle("", isOn: settings.$isLunarVisible)
                    .toggleStyle(.switch)
            }
        }
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 100))
        Spacer()
    }
    
}

#Preview {
    SettingLayoutView()
}
