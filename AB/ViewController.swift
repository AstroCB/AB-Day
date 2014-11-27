//
//  ViewController.swift
//  AB
//
//  Created by Cameron Bernhardt on 9/14/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

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

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initial = true
        request = getData()
        connected = true
        
        calendar.backgroundColor = UIColor(white: 1, alpha: 0.5)
        calendar.timeZone = NSTimeZone(abbreviation: "EDT")
        
        load(NSDate())
        
        calendar.hidden = true
        ab.hidden = false
        another.hidden = false
        reload.setTitle("Reload", forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var ab: UILabel!
    @IBOutlet weak var reload: UIButton!
    @IBOutlet weak var calendar: UIDatePicker!
    @IBOutlet weak var another: UIButton!
    @IBOutlet weak var dateString: UILabel!
    
    var initial: Bool = true
    var request: NSData?
    var connected: Bool = true
    var today: Bool = false
    
    func getJSON(urlToRequest: String) -> NSData? {
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary? {
        var error: NSError?
        if let JSON: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            return JSON
        }
        
        return nil
    }
    
    @IBAction func getDate() {
        if(today) { // Toggle button function between one that loads today and one that opens the datepicker (messy to avoid adding another button)
            calendar.setDate(NSDate(), animated: true)
            today = false
        } else {
            calendar.hidden = false
            ab.hidden = true
            
            another.setTitle("Today", forState: UIControlState.Normal)
            reload.setTitle("Load", forState: UIControlState.Normal)
            
            today = true
        }
    }
    
    @IBAction func refresh() {
        reload.setTitle("Reload", forState: UIControlState.Normal)
        another.setTitle("Another Date?", forState: UIControlState.Normal)
        
        if(connected) {
            load(calendar.date)
            today = false
        } else {
            request = getData()
            connected = true
        }
    }
    
    func getData() -> NSData? {
        return getJSON("https://dl.dropboxusercontent.com/u/56017856/dates.json")
    }
    
    func load(date: NSDate) {
        calendar.hidden = true
        ab.hidden = false
        another.hidden = false
        
        // Make date readable; display it
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        
        // Set font sizes to fit screens properly
        if UIScreen.mainScreen().bounds.width < 375 {
            dateString.font = UIFont.systemFontOfSize(20.00)
        } else if UIScreen.mainScreen().bounds.width == 375{
            dateString.font = UIFont.systemFontOfSize(25.00)
        } else {
            dateString.font = UIFont.systemFontOfSize(30.00)
        }
        
        let strDate = dateFormatter.stringFromDate(date)
        dateString.text = strDate
        
        if let req = request {
            var data = parseJSON(req)!
            
            dateFormatter.dateStyle = .ShortStyle
            let keyArr: [String] = dateFormatter.stringFromDate(date).split("/")
            
            let keyStr = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
            
            if let abDay: String = data.valueForKey(keyStr) as? String {
                if abDay == "PD" {
                    ab.font = UIFont.systemFontOfSize(20)
                    ab.numberOfLines = 2 // Add a line to fit the following
                    ab.text = "Professional Development Day\n(No School)"
                } else {
                    ab.font = UIFont.systemFontOfSize(100)
                    ab.numberOfLines = 1
                    ab.text = abDay
                }
            } else {
                ab.font = UIFont.systemFontOfSize(20)
                ab.text = "No School"
            }
        } else {
            connected = false
        }
    }
}