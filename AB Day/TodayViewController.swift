//
//  TodayViewController.swift
//  AB Day
//
//  Created by Cameron Bernhardt on 11/4/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var abField: UILabel!
    
    func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
            return UIEdgeInsetsZero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() -> String? {
        let data: NSData? = NSData(contentsOfURL: NSURL(string: "https://dl.dropboxusercontent.com/u/56017856/dates.json")!)
        
        if let req = data {
            var parsedData: NSDictionary?
            var error: NSError?
            if let JSON: NSDictionary = NSJSONSerialization.JSONObjectWithData(req, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
                parsedData = JSON
            }

            if let newData = parsedData {
                // See ViewController.swift for explanation
                let cal: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
                let components = cal.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: NSDate())
                let newDate: NSDate = cal.dateFromComponents(components)!
                
                var timeSince1970: String = "\(newDate.timeIntervalSince1970 * 1000)"
                let end = advance(timeSince1970.endIndex, -2)
                let range: Range<String.Index> = Range<String.Index>(start: timeSince1970.startIndex, end: end)
                timeSince1970 = timeSince1970.substringWithRange(range)
                
                return parsedData!.valueForKey(timeSince1970) as? String
            }
        }
        return nil
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if let abDay: String = getData() {
            abField.text = abDay + " Day"
        } else {
            abField.text = "No School"
        }
        
        completionHandler(NCUpdateResult.NewData)
    }
    
}
