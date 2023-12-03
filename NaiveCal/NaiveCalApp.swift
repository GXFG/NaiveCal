import SwiftUI

@main
struct NaiveCalApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @StateObject var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
