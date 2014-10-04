//
//  ViewController.swift
//  AB
//
//  Created by Cameron Bernhardt on 9/14/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController, ADBannerViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initial = true
        
        let now: NSDate = NSDate()
        load(now)
        
        calendar.hidden = true
        ab.hidden = false
        another.hidden = false
        reload.setTitle("Reload", forState: UIControlState.Normal)
        
        curDate = now
        
        self.canDisplayBannerAds = true
        self.ad.delegate = self
        self.ad.alpha = 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var ab: UILabel!
    @IBOutlet weak var reload: UIButton!
    @IBOutlet weak var ad: ADBannerView!
    @IBOutlet weak var calendar: UIDatePicker!
    @IBOutlet weak var another: UIButton!
    
    var initial: Bool = true
    var curDate = NSDate() //store current date, initialize as today
    
    func getJSON(urlToRequest: String) -> NSData {
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary? {
        var error: NSError?
        if let JSON: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary {
            return JSON
        }
        
        return nil
    }
    
    @IBAction func getDate() {
        calendar.hidden = false
        ab.hidden = true
        another.hidden = true
        reload.setTitle("Load", forState: UIControlState.Normal)
    }
    
    @IBAction func refresh() {
        if(initial){
            load(NSDate())
        }else{
            load(calendar.date)
        }
        
        initial = false

        load(curDate)
    }
    
    func load(date: NSDate) {
        var request: NSData? = getJSON("https://dl.dropboxusercontent.com/u/56017856/dates.json")
        
        calendar.hidden = true
        ab.hidden = false
        another.hidden = false
        
        if let req = request {
            var data = parseJSON(req)!
            curDate = date
            
            //create a new NSDate object starting at midnight on the specified day by using NSCalendar and pulling in date's components
            let cal: NSCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
            let newDate: NSDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
            
            let timeSince1970: String = "\(Int(newDate.timeIntervalSince1970 as Double * 1000))" //collect time in seconds since 1970 and convert to milliseconds to access day key in data Dictionary
            
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
        }
    }
}