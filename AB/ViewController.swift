//
//  ViewController.swift
//  AB
//
//  Created by Cameron Bernhardt on 9/14/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initial = true
        request = getData()
        connected = true
        
        calendar.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        let now: NSDate = NSDate()
        load(now)
        
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
        if(today) { //toggle button function between one that loads today and one that opens the datepicker (messy to avoid adding another button)
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
        
        //make date readable, display it
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        
        let strDate = dateFormatter.stringFromDate(date)
        dateString.text = strDate
        
        if let req = request {
            var data = parseJSON(req)!
            
            //create a new NSDate object starting at midnight on the specified day by using NSCalendar and pulling in date's components
            let cal: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
            let components = cal.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: date)
            let newDate: NSDate = cal.dateFromComponents(components)!
            
            //because the values stored are larger than the Integer data type can hold, you must calculate the time since epoch as a Double type, interpolate it in a String, and shave off the last two characters (.0) to get it into a String form (quite messy - if you're reading this ten years later and you know how to fix this, please do so)
            var timeSince1970: String = "\(newDate.timeIntervalSince1970 * 1000)" //collect time in seconds since 1970 and convert to milliseconds to access day key in data Dictionary
            let end = advance(timeSince1970.endIndex, -2)
            let range: Range<String.Index> = Range<String.Index>(start: timeSince1970.startIndex, end: end)
            timeSince1970 = timeSince1970.substringWithRange(range)
            
            if let abDay: String = data.valueForKey(timeSince1970) as? String{
                if abDay == "PD" {
                    ab.font = UIFont.systemFontOfSize(20)
                    ab.numberOfLines++ //add a line to fit the following
                    ab.text = "Professional Development Day\n(No School)"
                } else {
                    ab.font = UIFont.systemFontOfSize(100)
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