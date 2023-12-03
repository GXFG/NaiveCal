import SwiftUI

@main
struct NaiveCalApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 350, height: 350)
                .environmentObject(store)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
