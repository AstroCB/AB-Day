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
        
        // Sort string dates by converting them to Dates and using the built-in comparison operator
        let sortedArr: [(String, String)] = data.sorted(by: { a,b in return td(a.0) < td(b.0) })
        print(sortedArr)
        
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
    
    /**
     Converts `String` to `Date`
     - parameters:
        - dateString: `String` in desired format
        - format: Format to use for conversion (default `M/dd/yy`) – see [formatting docs](http://userguide.icu-project.org/formatparse/datetime/)
     - returns: Converted `Date` object
     */
    func td(_ dateString: String, withFormat format: String = "M/dd/yy") -> Date {
        let dFormat: DateFormatter = DateFormatter()
        dFormat.dateFormat = format
        if let d: Date = dFormat.date(from: dateString) {
            return d
        } else if format == "M/dd/yy" {
            // 1 recursion max
            return td(dateString, withFormat: "MM/dd/yy")
        }
        return Date()
    }
}
