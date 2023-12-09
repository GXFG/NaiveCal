import SwiftUI

@main
struct NaiveCalApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {}
        //        WindowGroup {
        //            SettingView()
        //                .environmentObject(store)
        //        }
        //        .defaultSize(width: 600, height: 500)
        //        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
