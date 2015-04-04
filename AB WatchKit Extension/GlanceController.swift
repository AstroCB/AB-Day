//
//  GlanceController.swift
//  AB WatchKit Extension
//
//  Created by Cameron Bernhardt on 4/3/15.
//  Copyright (c) 2015 Cameron Bernhardt. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    
    @IBOutlet var day: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.setLabelText("-", withSize: 100) // Initialize label
        
        if let abDay: String = getDay(forDate: NSDate()) {
            if abDay != "failed" {
                self.setLabelText(abDay + " Day", withSize: 45)
            }
        } else {
            self.setLabelText("No School", withSize: 15)
        }
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func setLabelText(text: String, withSize size: CGFloat) {
        let font: UIFont = UIFont.systemFontOfSize(size)
        let attrString: NSAttributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        self.day.setAttributedText(attrString)
    }
    
}
