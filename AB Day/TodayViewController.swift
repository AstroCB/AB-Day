//
//  TodayViewController.swift
//  AB Day
//
//  Created by Cameron Bernhardt on 11/4/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit
import NotificationCenter

extension String {
    public func split(separator: String) -> [String] {
        if separator.isEmpty {
            return map(self) { String($0) }
        }
        if var pre = self.rangeOfString(separator) {
            var parts = [self.substringToIndex(pre.startIndex)]
            while let rng = self.rangeOfString(separator, range: pre.endIndex..<endIndex) {
                parts.append(self.substringWithRange(pre.endIndex..<rng.startIndex))
                pre = rng
            }
            parts.append(self.substringWithRange(pre.endIndex..<endIndex))
            return parts
        } else {
            return [self]
        }
    }
}

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
                let date: NSDate = NSDate()
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .ShortStyle
                let keyArr: [String] = dateFormatter.stringFromDate(date).split("/")
                
                let keyStr: String = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
                return newData.valueForKey(keyStr) as? String
            }
        }
        return "no_connection"
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if let abDay: String = getData() {
            if abDay == "no_connection" {
                abField.text = "-"
                completionHandler(NCUpdateResult.Failed)
            } else {
                abField.text = abDay + " Day"
            }
        } else {
            abField.text = "No School"
        }
        
        completionHandler(NCUpdateResult.NewData)
    }
    
}
