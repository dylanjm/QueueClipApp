//
//  InformationViewController.swift
//  QueueClipApp
//
//  Created by Dylan McDowell on 8/13/16.
//  Copyright © 2016 Dylan McDowell. All rights reserved.
//

import Cocoa

class InformationViewController: NSViewController {
    @IBOutlet var imageView: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        imageView.image = NSImage(named: "QueueClipApp")
    }
    
}
