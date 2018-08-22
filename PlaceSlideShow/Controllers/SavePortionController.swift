//
//  SavePortionController.swift
//  PlaceSlideShow
//
//  Created by Austin on 8/19/18.
//  Copyright © 2018 Austin. All rights reserved.
//

import Cocoa

class SavePortionController: NSViewController {
    var place:Place?
    
    @IBOutlet weak var startIndex: NSTextField!
    @IBOutlet weak var saveLocation: NSTextField!
    @IBOutlet weak var stopIndex: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startIndex.integerValue = 0
        var contentsCount:Int = 0
        if(place != nil){
            if(place?.getContentsCount() != nil){
                contentsCount = (place?.getContentsCount())!
            }
        }
        stopIndex.integerValue = contentsCount
    }
    
}
