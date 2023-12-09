import Cocoa
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow?
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory) // 应用程序的激活策略为 accessory
        setupPopover()
        setupStatusBarItem()
        checkFirstLaunch()
    }
    
    func applicationWillTerminate(_ notification: Notification) {}
    
    func setupPopover() {
        let contentView = ContentView()
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
    }
    
    func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "calendar", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 17, weight: .regular))
            button.action = #selector(clickStatusIcon(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.menu = createMenu()
            button.target = self
        }
    }
    
    func checkFirstLaunch() {
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        if !isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showPopover()
            }
        }
    }
    
    func showPopover() {
        if let button = statusBarItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func showContextMenu() {
        if let button = statusBarItem.button {
            let buttonFrame = button.window?.convertToScreen(button.frame) ?? NSRect.zero
            let menuOrigin = NSPoint(x: buttonFrame.minX, y: buttonFrame.minY - 3)
            statusBarItem.button?.menu?.popUp(positioning: nil, at: menuOrigin, in: nil)
        }
    }
    
    @objc func clickStatusIcon(_ sender: Any?) {
        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            showContextMenu()
        } else {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                showPopover()
            }
        }
    }
    
    @objc func createMenu() -> NSMenu {
        let menu = NSMenu()
        let settingLabel = NSLocalizedString("setting", comment: "")
        let quitLabel = NSLocalizedString("quit", comment: "")
        let settingsItem = NSMenuItem(title: settingLabel, action: #selector(openSettingView(_:)), keyEquivalent: ",")
        let quitItem = NSMenuItem(title: quitLabel, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(settingsItem)
        menu.addItem(quitItem)
        return menu
    }
    
    @objc func openSettingView(_ sender: Any?) {
        let settingView = SettingView()
        let settingViewController = NSHostingController(rootView: settingView)
        let settingWindow = NSWindow(contentViewController: settingViewController)
        settingWindow.setContentSize(NSSize(width: 500, height: 400))
        settingWindow.title = "NaiveCal"
//        settingWindow.title = NSLocalizedString("setting", comment: "")
//        settingWindow.titleVisibility = .hidden
//        settingWindow.titlebarAppearsTransparent = true // 设置标题栏透明
        settingWindow.styleMask.insert(.fullSizeContentView)
        settingWindow.center()
        settingWindow.makeKeyAndOrderFront(nil) // 使窗口成为主窗口并将其置于前面
        settingWindow.isReleasedWhenClosed = false // 窗口关闭时不释放对象
        NSApp.activate(ignoringOtherApps: true) // 激活应用程序，忽略其他应用程序
    }
}

