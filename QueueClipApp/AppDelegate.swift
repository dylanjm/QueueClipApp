//
//  AppDelegate.swift
//  QueueClipApp
//
//  Created by Dylan McDowell on 8/11/16.
//  Copyright © 2016 Dylan McDowell. All rights reserved.
//

import Cocoa
import AppKit
import MASShortcut

// Top-Level Variables
var clipHistory = [String]()
var clipboard = NSPasteboard.generalPasteboard()
let popover = NSPopover()
let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
var distributeBool: Bool!
let infoPopover = NSPopover()

/**
 * Notification Center Delegate Class - used to show notifications even
 * when QueueClip is the app in focus
 */
class MyNotificationDelegate: NSObject {
    func setNotification(title: String, message: String)
    {
        let notification: NSUserNotification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
}

/**
 * AppDelegate Class - I'm not super familiar with swift but I imagine this 
 * is something close to an Application class. All my methods are pretty much written
 * in this class. Probably will edit at as time goes on.
 */
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    // Class Variables
    var timer = NSTimer()
    var recentValue =  ""
    var currentClipHistIndex = 0
    var recordingBool: Bool!
    var eventMonitor: EventMonitor?
    
    /********************************************
    * MENU ITEM - Recording Queue Functionality
    * These functions are all encompassed under
    * the "Record Queue" menu item
    *********************************************/
    func toggleRecordQueue() {
        if recordingBool == false {
            startRecordQueue()
            recordingBool = true
        } else {
            stopRecordQueue()
            recordingBool = false
        }
    }
    
    // Method starts listening for changes in the
    // clipboard. This function runs off NSTimer() every 1 second
    func startRecordQueue() {
        print("Recording Queue")
        recordingBool = true
        distributeBool = false
        clipboard.clearContents()
        clipWatcher()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self,
                                                       selector: #selector(clipWatcher),
                                                       userInfo: nil, repeats: true)
        statusItem.button?.image = NSImage(named:"QueueClipIconGreen")
        
    }
    
    // Stops recording queue and timer
    func stopRecordQueue(){
        print("Recording Stopped")
        timer.invalidate()
        recordingBool = false
        statusItem.button?.image = NSImage(named:"QCIconBlack")
    }
    
    // Compares current clipboard with recent_value and if
    // they are different then it stores the new value
    func clipWatcher(){
        print("Listening...")
        let tmpValue = clipboard.stringForType(NSPasteboardTypeString)
        if tmpValue != recentValue {
            recentValue = (tmpValue != nil ? tmpValue! : "")
            if clipBoardIsNotEmpty(recentValue){
                printToConsole(recentValue)
                storeClipboardHistory(recentValue)
            }
        }
    }
    
    // Function to determine that clipboard is not empty
    func clipBoardIsNotEmpty(value: String) -> Bool{
        if value.isEmpty{
            return false
        } else {
            return true
        }
    }
    
    // Prints the change to console -
    // might get rid of this function to clean up the code later.
    func printToConsole(value: String){
        print("Clipboard Changed: " + value)
    }
    
    // This function adds the new value to the end
    // of the array
    func storeClipboardHistory(value: String){
        clipHistory.append(value)
    }
    
    /********************************************
     * MENU ITEM - Distribute Queue Functionality
     * These functions are all encompassed under
     * the "Distribute Queue" menu item
     *********************************************/
    func toggleDistributeQueue(option: Int) {
        if distributeBool == true {
            distributeBool = false
            if popover.shown{
                popover.close()
            }
            statusItem.button?.image = NSImage(named: "QCIconBlack")
        } else {
            if option == 1 {
                shortcutDistributeQueue()
                distributeBool = true
            } else {
                distributeQueue()
                distributeBool = true
            }
        }
    }
    
    // Menu Function - Stops recording and
    // pops up the QueueClip popover
    func distributeQueue() {
        print("Distributing Queue")
        distributeBool = true
        recordingBool = false
        timer.invalidate()
        togglePopover()
        if clipHistory.count > 0 {
            clipboard.clearContents()
            clipboard.setString(clipHistory[0], forType: NSPasteboardTypeString)
            print("QueueClip Set: " + clipHistory[0])
        }
    }
    
    // Provides the same functionality of the function above
    // but doesn't open the popover for shortcut functionality
    func shortcutDistributeQueue() {
        print("Distributing Queue")
        distributeBool = true
        recordingBool = false
        timer.invalidate()
        if clipHistory.count > 0 {
            clipboard.clearContents()
            clipboard.setString(clipHistory[0], forType: NSPasteboardTypeString)
            print("QueueClip Set: " + clipHistory[0])
        }
        statusItem.button?.image = NSImage(named: "QueueClipIconOrange")
    }
    
    // Does at it says - toggles popover when clicked
    func togglePopover() {
        if popover.shown {
            closePopover()
            statusItem.button?.image = NSImage(named: "QCIconBlack")
        } else {
            showPopover()
            statusItem.button?.image = NSImage(named: "QueueClipIconOrange")
        }
    }
    
    // Shows popover changes Icon color
    func showPopover() {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button,
                                       preferredEdge: NSRectEdge.MinY)
        }
    }
    
    // Close popover
    func closePopover() {
        popover.close()
        distributeBool = false
    }
    
    // These functions are only used when the user
    // is using the app's shortcuts to increment through
    // their QueueClip. Otherwise the use has to use the 
    // popover to increment through the list.
    func decrementQueueClip(){
        if !popover.shown {
            if clipHistory.count > 0 {
                currentClipHistIndex = (currentClipHistIndex - 1 + clipHistory.count) % clipHistory.count
                clipboard.clearContents()
                clipboard.setString(clipHistory[currentClipHistIndex], forType: NSPasteboardTypeString)
                print("QueueClip Set: " + clipHistory[currentClipHistIndex])
            }
        }
    }
    
    // Same idea as above
    func incrementQueueClip(){
        if !popover.shown {
            if clipHistory.count > 0 {
                currentClipHistIndex = (currentClipHistIndex + 1) % clipHistory.count
                clipboard.clearContents()
                clipboard.setString(clipHistory[currentClipHistIndex], forType: NSPasteboardTypeString)
                print("QueueClip Set: " + clipHistory[currentClipHistIndex])
            }
        }
    }
    
    /********************************************
     * MENU ITEM - Clear Queue Functionality
     * These functions are all encompassed under
     * the "Clear Queue" menu item
     *********************************************/
    func clearClipHistory(){
        print("QueueClip Cleared")
        recordingBool = false
        distributeBool = false
        clipHistory.removeAll()
        showNotification()
        statusItem.button?.image = NSImage(named: "QCIconBlack")
    }
    
    //Shows Clear Queue Notification
    func showNotification() -> Void {
        let notification: MyNotificationDelegate = MyNotificationDelegate()
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self;
        notification.setNotification("Queue Cleared", message: "Your QueueClip has been cleared!")
    }
    
    // Allows Notifcation to be seen despite what app is currently active
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    /***************************************************
     * Shortcut and Information Popover - these functions
     * open and close the popover and monitor clicking events
     * so that it will automatically close when the user
     * clicks away from it. 
     ****************************************************/
    // Does at it says - toggles popover when clicked
    func toggleInfoPop() {
        if infoPopover.shown {
            closeInfoPopover()
        } else {
            showInfoPopover()
        }
    }
    
    // Shows popover changes Icon color
    func showInfoPopover() {
        if let button = statusItem.button {
            eventMonitor?.start()
            infoPopover.showRelativeToRect(button.bounds, ofView: button,
                                       preferredEdge: NSRectEdge.MinY)
        }
    }
    
    // Close popover
    func closeInfoPopover() {
        infoPopover.close()
        eventMonitor?.stop()
    }
    
    

    /********************************************
     * App Runner - loads the entire APP
     * This is as close to the "main" function I
     * guess we'll get. I am still learning swift.
     *********************************************/
    weak var window: NSWindow!
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: "QCIconBlack")
            recordingBool = false
            distributeBool = false
        }
        
        // Popover Declaration
        popover.contentViewController = QueueClipController(nibName: "QueueClipController", bundle: nil)
        infoPopover.contentViewController = InformationViewController(nibName: "InformationViewController",
                                                                      bundle: nil)
        
        eventMonitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) { [unowned self] event in
            if infoPopover.shown {
                self.closeInfoPopover()
            }
        }
        eventMonitor?.start()
        
        // Menu Items
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Record Queue", action: #selector(AppDelegate.toggleRecordQueue), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Distribute Queue", action: #selector(AppDelegate.toggleDistributeQueue), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Clear Queue", action: #selector(AppDelegate.clearClipHistory), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Shortcuts & Info", action: #selector(AppDelegate.toggleInfoPop), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit QueueClip", action: #selector(NSApplication.sharedApplication().terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        // Record Queue Shortcut
        let recordShortcut = MASShortcut.init(keyCode: UInt(kVK_ANSI_R), modifierFlags: UInt(NSEventModifierFlags.ControlKeyMask.rawValue + NSEventModifierFlags.AlternateKeyMask.rawValue + NSEventModifierFlags.CommandKeyMask.rawValue))
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(recordShortcut, withAction: {
            self.toggleRecordQueue()
        })
        
        // Distribute Queue Shortcut
        let distributeShortcut = MASShortcut.init(keyCode: UInt(kVK_ANSI_D), modifierFlags: UInt(NSEventModifierFlags.ControlKeyMask.rawValue + NSEventModifierFlags.AlternateKeyMask.rawValue + NSEventModifierFlags.CommandKeyMask.rawValue))
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(distributeShortcut, withAction: {
            self.toggleDistributeQueue(1)
        })
        
        
        // Clear Queue Shortcut
        let clearQueueShortcut = MASShortcut.init(keyCode: UInt(kVK_ANSI_K), modifierFlags: UInt(NSEventModifierFlags.ControlKeyMask.rawValue + NSEventModifierFlags.AlternateKeyMask.rawValue + NSEventModifierFlags.CommandKeyMask.rawValue))
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(clearQueueShortcut, withAction: {
            self.clearClipHistory()
        })
        
        // Increment Queue Shortcut
        let incrementQueueClipSC = MASShortcut.init(keyCode: UInt(kVK_ANSI_Period), modifierFlags: UInt(NSEventModifierFlags.CommandKeyMask.rawValue))
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(incrementQueueClipSC, withAction: {
            if distributeBool == true && self.recordingBool == false && clipHistory.count > 0 {
                self.incrementQueueClip()
            }
        })
        
        // Decrement Queue Shortcut
        let decrementQueueClipSC = MASShortcut.init(keyCode: UInt(kVK_ANSI_Comma), modifierFlags: UInt(NSEventModifierFlags.CommandKeyMask.rawValue))
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(decrementQueueClipSC, withAction: {
            if distributeBool == true && self.recordingBool == false && clipHistory.count > 0 {
                self.decrementQueueClip()
            }
        })
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        MASShortcutMonitor.sharedMonitor().unregisterAllShortcuts()
    }
    
    
    
}



