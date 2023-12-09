import SwiftUI

struct SettingView: View {
    private let navigationItems = [
        SettingLabel(title: NSLocalizedString("general", comment: ""), value: "general"),
        SettingLabel(title: NSLocalizedString("layout", comment: ""), value: "layout"),
        SettingLabel(title: NSLocalizedString("about", comment: ""), value: "about"),
    ]
    
    @State private var selectedNavItem: String? = "general"
    
    var body: some View {
        NavigationView {
            List(navigationItems, id: \.value) { menu in
                NavigationLink(destination: detailView(for: menu.value), tag: menu.value, selection: $selectedNavItem) {
                    Text(menu.title)
                }
            }
            .listStyle(SidebarListStyle())
            
            detailView(for: selectedNavItem)
        }
        .frame(minWidth: 300)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Text("")
            }
        }
    }
    
    @ViewBuilder
    private func detailView(for itemValue: String?) -> some View {
        Group {
            if itemValue == "general" {
                SettingGeneralView()
            } else if itemValue == "layout" {
                SettingLayoutView()
            } else if itemValue == "about" {
                SettingAboutView()
            } else {
                Text(NSLocalizedString("settingSelectACategory", comment: ""))
            }
        }
    }
}

#Preview {
    SettingView()
}
