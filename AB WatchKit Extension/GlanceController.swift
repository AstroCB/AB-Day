//
//  GlanceController.swift
//  AB WatchKit Extension
//
//  Created by Cameron Bernhardt on 4/3/15.
//  Copyright (c) 2015 Cameron Bernhardt. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: InterfaceController { // Subclass IC class b/c it does all the work already
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
