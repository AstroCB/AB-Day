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
        
        // Set font sizes to fit screens properly
        if UIScreen.mainScreen().bounds.width < 375 {
            dateString.font = UIFont.systemFontOfSize(20.00)
        } else if UIScreen.mainScreen().bounds.width == 375{
            dateString.font = UIFont.systemFontOfSize(25.00)
        } else {
            dateString.font = UIFont.systemFontOfSize(30.00)
        }
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
        
        let strDate = dateFormatter.stringFromDate(date)
        dateString.text = strDate
        
        if let req = request {
            var data = parseJSON(req)!
            
            dateFormatter.dateStyle = .ShortStyle
            let keyArr: [String] = dateFormatter.stringFromDate(date).split("/")
            let keyStr = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
            
            //calendar.maximumDate =
            
            let datesArr: NSArray = data.allKeys
            var newDates: [NSDate] = [NSDate]()
            
            for i in datesArr {
                if let myDate: String = i as? String {
                    let year: String = myDate.substringFromIndex(advance(myDate.endIndex, -4))
                    let dayMonth: String = myDate.substringToIndex(advance(myDate.endIndex, -4))
                    
                    // This is where it gets tricky; so the dates are received in the format M(M)D(D)YYYY, so I don't know whether the date and/or the month is/are one/two digits
                    
                    var month: String = ""
                    var day: String = ""
                    
                    if countElements(dayMonth) == 2 { // MD
                        day = dayMonth.substringFromIndex(advance(dayMonth.endIndex, -1))
                        month = dayMonth.substringToIndex(advance(dayMonth.endIndex, -1))
                    } else if countElements(dayMonth) == 3 { // MMD || MDD
                        var preMonth: String = ""
                        var preDay: String = ""
                        
                        if year == "2014" {
                            preMonth = dayMonth.substringToIndex(advance(dayMonth.endIndex, -1))
                            preDay = dayMonth.substringFromIndex(advance(dayMonth.endIndex, -1))
                        } else if year == "2015" {
                            preMonth = dayMonth.substringToIndex(advance(dayMonth.endIndex, -2))
                            preDay = dayMonth.substringFromIndex(advance(dayMonth.endIndex, -2))
                        } else {
                            // Expand later
                        }
                        if preDay.toInt() >= 1 && preMonth.toInt() <= 12 {
                            day = preDay
                            month = preMonth
                        } else {
                            day = dayMonth.substringFromIndex(advance(dayMonth.endIndex, -2))
                            month = dayMonth.substringToIndex(advance(dayMonth.endIndex, -2))
                        }
                        
                    } else { // MMDD
                        day = dayMonth.substringFromIndex(advance(dayMonth.endIndex, -2))
                        month = dayMonth.substringToIndex(advance(dayMonth.endIndex, -2))
                    }
                    let dateString: String = "\(month)/\(day)/\(year)"
                    // I can't believe that that actually just worked
                    
                    if let dateToAppend: NSDate = dateFormatter.dateFromString(dateString) {
                        newDates.append(dateToAppend)
                    }
                }
            }
            
            var descriptor: NSSortDescriptor = NSSortDescriptor(key: "", ascending: true)
            var sortedResults: NSArray = datesArr.sortedArrayUsingDescriptors([descriptor])
            
            //            println(sortedResults)
            
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