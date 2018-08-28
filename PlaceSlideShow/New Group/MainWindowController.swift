//
//  MainWindowController.swift
//  PlaceSlideShow
//
//  Created by Austin on 8/28/18.
//  Copyright © 2018 Austin. All rights reserved.
//

import Foundation
import Cocoa

class MainWindowController: NSWindowController {
    private var mainViewController:MainViewController?
    func setMainViewController(vc:MainViewController){
        self.mainViewController = vc
    }
    override func windowDidLoad() {
        setMainViewController(vc: self.contentViewController as! MainViewController)
    }
    func windowDidResize(_ notification: Notification) {
        mainViewController?.updateInfoBar()
    }
    
}
