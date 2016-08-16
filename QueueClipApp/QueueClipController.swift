//
//  QueueClipController.swift
//  QueueClipApp
//
//  Created by Dylan McDowell on 8/11/16.
//  Copyright © 2016 Dylan McDowell. All rights reserved.
//

import Cocoa

/******************************************
 * NSView Controller - This class controls
 * how the popover looks and feels along
 * with some error handling and informaition
 * for the user.
 ******************************************/
class QueueClipController: NSViewController {
    // Text Labels
    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var arrayCount: NSTextField!
    @IBOutlet var clipMessage: NSTextField!
    
    var currentClipHistIndex: Int = 0 {
        didSet {
            updateClipHist()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        currentClipHistIndex = 0
        clipMessage.alphaValue = 0
        if clipHistory.count > 0{
            startFade()
        }
    }
    
    func updateClipHist() {
        if clipHistory.count <= 0{
            textLabel.stringValue = "Your queue is currently empty!"
            arrayCount.stringValue = ""
        }
        else {
            let clipString = clipHistory[currentClipHistIndex]
            let trimmedClip = clipString.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
            textLabel.stringValue = String(trimmedClip)
            let countArray: String = "\(currentClipHistIndex + 1)/\(clipHistory.count)"
            arrayCount.stringValue = countArray
        }
    }
    
    
}

extension QueueClipController {
    @IBAction func goLeft(sender: NSButton) {
        if clipHistory.count > 0 {
            currentClipHistIndex = (currentClipHistIndex - 1 + clipHistory.count) % clipHistory.count
            clipboard.clearContents()
            clipboard.setString(clipHistory[currentClipHistIndex], forType: NSPasteboardTypeString)
            print("QueueClip Set: " + clipHistory[currentClipHistIndex])
            startFade()
        }

    }
    
    @IBAction func goRight(sender: NSButton) {
        clipMessage.layer?.removeAllAnimations()
        if clipHistory.count > 0 {
            currentClipHistIndex = (currentClipHistIndex + 1) % clipHistory.count
            clipboard.clearContents()
            clipboard.setString(clipHistory[currentClipHistIndex], forType: NSPasteboardTypeString)
            print("QueueClip Set: " + clipHistory[currentClipHistIndex])
            startFade()
        }
        
    }
    
    @IBAction func close(sender: NSButton) {
        popover.close()
        statusItem.button?.image = NSImage(named: "QCIconBlack")
        distributeBool = false
    }
    
    func startFade()
    {
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.5
            self.clipMessage.animator().alphaValue = 1
            }, completionHandler: { () -> Void in
                
                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                    context.duration = 1
                    self.clipMessage.animator().alphaValue = 0
                    }, completionHandler: { 
                        
                })
        })
    }

}
