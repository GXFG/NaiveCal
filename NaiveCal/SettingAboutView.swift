import SwiftUI
import LaunchAtLogin

struct SettingAboutView: View {
    @StateObject var settings = AppSettings()
    
    var body: some View {
        VStack {
            HStack {
                Link("Github", destination: URL(string: "https://github.com/GXFG/naivecal-macOS")!)
            }
        }
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 100))
        Spacer()
    }
    
}

#Preview {
    SettingAboutView()
}

