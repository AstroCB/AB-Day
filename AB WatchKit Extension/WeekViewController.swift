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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        if let data: [String: String] = context as? [String: String] {
            self.fillTable(data)
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
    
    
    func fillTable(_ data: [String: String]) {
        self.dayTable.setNumberOfRows(data.count, withRowType: "DayRow")
        
        // Sort by date
        let sortedArr: [(String, String)] = data.sorted(by: { a,b in return a.0 < b.0 })
        
        for (index, vals) in sortedArr.enumerated() { // Format -> index: Int, (day, dayType): (String, String)
            if let row: TableRowController = self.dayTable.rowController(at: index) as? TableRowController {
                row.dateLabel.setText(vals.0) // Set day
                var displayString: String = ""
                if vals.1 == "No School" {
                    displayString = vals.1
                } else {
                    displayString = vals.1 + " Day"
                }
                row.dayTypeLabel.setText(displayString) // Set day type
            }
        }
    }
}
