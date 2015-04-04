//
//  InterfaceController.swift
//  AB WatchKit Extension
//
//  Created by Cameron Bernhardt on 4/3/15.
//  Copyright (c) 2015 Cameron Bernhardt. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var day: WKInterfaceLabel!
    @IBOutlet var later: WKInterfaceButton!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.setLabelText("-", withSize: 100) // Initialize label
        
        if let abDay: String = getDay(forDate: NSDate()) {
            if abDay != "failed" {
                self.setLabelText(abDay, withSize: 90)
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
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        if segueIdentifier == "toWeekView" {
            var daysDict: [String: String] = [String: String]()
            
            let today: NSDate = NSDate()
            for var i = 1; i < 6; i++ { // Get next five days
                // Day from reference point (1..5)
                let dayComponent: NSDateComponents = NSDateComponents()
                dayComponent.day = i;
                
                let cal: NSCalendar = NSCalendar.currentCalendar()
                if let nextDate: NSDate = cal.dateByAddingComponents(dayComponent, toDate: NSDate(), options: NSCalendarOptions.MatchFirst) {
                    
                    // Formatted date
                    let formatter: NSDateFormatter = NSDateFormatter()
                    formatter.dateStyle = NSDateFormatterStyle.ShortStyle
                    
                    let dayString: String = formatter.stringFromDate(nextDate) // Short date string for cell
                    
                    // Day value
                    if let dayType: String = getDay(forDate: nextDate) {
                        if dayType != "failed" {
                            // Add to dictionary
                            daysDict[dayString] = dayType
                        }
                    } else {
                        // Add to dictionary (no school)
                        daysDict[dayString] = "No School"
                    }
                }
            }
            return daysDict
        }
        return nil
    }
    
    func setLabelText(text: String, withSize size: CGFloat) {
        let font: UIFont = UIFont.systemFontOfSize(size)
        let attrString: NSAttributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        self.day.setAttributedText(attrString)
    }
}

public func getDay(forDate date: NSDate) -> String? {
    let data: NSData? = NSData(contentsOfURL: NSURL(string: "https://dl.dropboxusercontent.com/u/56017856/dates.json")!)
    
    if let req = data {
        var parsedData: NSDictionary?
        var error: NSError?
        if let JSON: NSDictionary = NSJSONSerialization.JSONObjectWithData(req, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            parsedData = JSON
        }
        
        if let newData: NSDictionary = parsedData {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            let keyArr: [String] = dateFormatter.stringFromDate(date).componentsSeparatedByString("/")
            
            let keyStr: String = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
            return newData.valueForKey(keyStr) as? String
        }
    }
    return "failed"
}
