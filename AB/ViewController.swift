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
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.initial = true
        self.request = getData()
        self.connected = true
        
        self.calendar.backgroundColor = UIColor(white: 1, alpha: 0.5)
        self.calendar.timeZone = NSTimeZone(abbreviation: "EDT")
        
        self.load(NSDate())
        
        self.calendar.hidden = true
        self.ab.hidden = false
        self.another.hidden = false
        self.reload.setTitle("Reload", forState: UIControlState.Normal)
        
        // Set font sizes to fit screens properly
        if UIScreen.mainScreen().bounds.width < 375 {
            self.dateString.font = UIFont.systemFontOfSize(20.00)
        } else if UIScreen.mainScreen().bounds.width == 375{
            self.dateString.font = UIFont.systemFontOfSize(25.00)
        } else {
            self.dateString.font = UIFont.systemFontOfSize(30.00)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        if self.today { // Toggle button function between one that loads today and one that opens the datepicker (messy to avoid adding another button)
            self.calendar.setDate(NSDate(), animated: true)
            self.today = false
        } else {
            self.calendar.hidden = false
            self.ab.hidden = true
            
            self.another.setTitle("Today", forState: UIControlState.Normal)
            self.reload.setTitle("Load", forState: UIControlState.Normal)
            
            self.today = true
        }
    }
    
    @IBAction func refresh() {
        self.reload.setTitle("Reload", forState: UIControlState.Normal)
        self.another.setTitle("Another Date?", forState: UIControlState.Normal)
        
        if self.connected {
            self.load(calendar.date)
            self.today = false
        } else {
            self.request = self.getData()
            self.connected = true
        }
    }
    
    func getData() -> NSData? {
        return self.getJSON("https://dl.dropboxusercontent.com/u/56017856/dates.json")
    }
    
    func load(date: NSDate) {
        self.calendar.hidden = true
        self.ab.hidden = false
        self.another.hidden = false
        
        // Make date readable; display it
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .FullStyle
        
        let strDate = dateFormatter.stringFromDate(date)
        self.dateString.text = strDate
        
        if let req = self.request {
            var data = self.parseJSON(req)!
            
            dateFormatter.dateStyle = .ShortStyle
            let keyArr: [String] = dateFormatter.stringFromDate(date).componentsSeparatedByString("/")
            let keyStr = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
            
            if let maxDate: String = data.valueForKey("maxDate") as? String {
                self.calendar.maximumDate = dateFormatter.dateFromString(maxDate)
            }
            
            if let abDay: String = data.valueForKey(keyStr) as? String {
                if abDay == "PD" {
                    self.ab.font = UIFont.systemFontOfSize(20)
                    self.ab.numberOfLines = 2 // Add a line to fit the following
                    self.ab.text = "Professional Development Day\n(No School)"
                } else {
                    self.ab.font = UIFont.systemFontOfSize(100)
                    self.ab.numberOfLines = 1
                    self.ab.text = abDay
                }
            } else {
                self.ab.font = UIFont.systemFontOfSize(20)
                self.ab.text = "No School"
            }
        } else {
            self.connected = false
        }
    }
}