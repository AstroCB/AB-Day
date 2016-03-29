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
            do {
                let JSON: NSDictionary = try NSJSONSerialization.JSONObjectWithData(req, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                parsedData = JSON
            } catch {
                print("Fetch failed: \((error as NSError).localizedDescription)")
            }
            
            if let newData = parsedData {
                let date: NSDate = NSDate()
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .ShortStyle
                let keyArr: [String] = dateFormatter.stringFromDate(date).componentsSeparatedByString("/")
                
                let keyStr: String = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
                return newData.valueForKey(keyStr) as? String
            }
        }
        return "no_connection"
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if let abDay: String = self.getData() {
            if abDay == "no_connection" {
                self.abField.text = "-"
                completionHandler(NCUpdateResult.Failed)
            } else {
                self.abField.text = abDay + " Day"
            }
        } else {
            self.abField.text = "No School"
        }
        
        completionHandler(NCUpdateResult.NewData)
    }
    
}
