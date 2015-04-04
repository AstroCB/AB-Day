//
//  WeekViewController.swift
//  AB
//
//  Created by Cameron Bernhardt on 4/4/15.
//  Copyright (c) 2015 Cameron Bernhardt. All rights reserved.
//

import WatchKit

class WeekViewController: WKInterfaceController {
    
    @IBOutlet var dayTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        if let data: [String: String] = context as? [String: String] {
            self.fillTable(data: data)
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
    
    
    func fillTable(#data: [String: String]) {
        self.dayTable.setNumberOfRows(data.count, withRowType: "DayRow")
        
        // Sort by date
        let sortedArr: [(String, String)] = sorted(data){ a,b in return a.0 < b.0 }
        
        for (index, vals) in enumerate(sortedArr) { // Format -> index: Int, (day, dayType): (String, String)
            if let row: TableRowController = self.dayTable.rowControllerAtIndex(index) as? TableRowController {
                row.dateLabel.setText(vals.0) // Set day
                row.dayTypeLabel.setText(vals.1) // Set day type
            }
        }
    }
}