import Cocoa
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow?
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
//        NSApp.setActivationPolicy(.accessory) // 设置应用程序的激活策略为 accessory
        let contentView = ContentView()
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient //点击其他区域时popover自动消失
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        self.statusBarItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        if let button = self.statusBarItem.button {
            let iconImage = NSImage(systemSymbolName: "calendar", accessibilityDescription: nil)
            if (iconImage != nil) {
                let size = NSSize(width: 50, height: 50)
                iconImage?.size = size
            }
            button.image = iconImage
            button.action = #selector(togglePopover(_:))
//            button.action = #selector(statusBarButtonClicked(_:))
//            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        window?.makeKeyAndOrderFront(self)
        return true
    }

    @objc func openMainWindow(_ sender: AnyObject?) {
        window?.orderFrontRegardless()
    }

    @objc func statusBarButtonClicked(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            print("Right click")
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Print", action: #selector(AppDelegate.printString(_:)), keyEquivalent: "P"))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            self.statusBarItem.menu = menu
        } else {
            print("Left click")
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                    self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }

    @objc func printString(_ sender: Any?) {
        print("Hello MacOS")
    }
}

