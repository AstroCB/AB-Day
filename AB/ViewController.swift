//
//  ViewController.swift
//  AB
//
//  Created by Cameron Bernhardt on 9/14/14.
//  Copyright (c) 2014 Cameron Bernhardt. All rights reserved.
//

import UIKit

struct JSON {
    var url: String
    
    func load() -> Data? {
        let urlT: URL = URL(string: url)!
        do {
            let data = try Data(contentsOf: urlT)
            return data
        } catch {
            print("Error: " + error.localizedDescription)
            return nil
        }
    }
    
    static func parse(_ data: Data?) -> NSDictionary {
        if let inputData: Data = data {
            do {
                if let JSON: NSDictionary = try JSONSerialization.jsonObject(with: inputData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    return JSON
                }
            } catch {
                print("Parse failed: \((error as NSError).localizedDescription)")
            }
        } else {
            print("Cannot parse invalid data")
        }
        return NSDictionary()
    }
}


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.initial = true
        self.request = getData()
        self.connected = true
        
        self.calendar.backgroundColor = UIColor(white: 1, alpha: 0.5)
        self.calendar.timeZone = TimeZone(abbreviation: "EDT")
        
        self.load(Date())
        
        self.calendar.isHidden = true
        self.ab.isHidden = false
        self.another.isHidden = false
        self.reload.isHidden = true
        
        self.configCircle()
        self.configButtons()
        
        // Set font sizes to fit screens properly
        if UIScreen.main.bounds.width < 375 {
            self.dateString.font = UIFont.systemFont(ofSize: 20.00)
        } else if UIScreen.main.bounds.width == 375{
            self.dateString.font = UIFont.systemFont(ofSize: 25.00)
        } else {
            self.dateString.font = UIFont.systemFont(ofSize: 30.00)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBOutlet weak var ab: UILabel!
    @IBOutlet weak var reload: UIButton!
    @IBOutlet weak var calendar: UIDatePicker!
    @IBOutlet weak var another: UIButton!
    @IBOutlet weak var dateString: UILabel!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var circleView: UIView!
    
    var initial: Bool = true
    var request: Data?
    var connected: Bool = true
    var today: Bool = false
    
    @IBAction func getDate() {
        if self.today { // Toggle button function between one that loads today and one that opens the datepicker (messy to avoid adding another button)
            self.calendar.setDate(Date(), animated: true)
            self.today = false
        } else {
            self.calendar.isHidden = false
            self.blurView.isHidden = false
            self.ab.isHidden = true
            
            self.another.setTitle("Today", for: UIControlState())
            self.reload.isHidden = false
            
            self.today = true
        }
    }
    
    @IBAction func refresh() {
        self.reload.isHidden = true
        self.another.setTitle("Another Date?", for: UIControlState())
        
        if self.connected {
            self.load(self.calendar.date)
            self.today = false
        } else {
            self.request = self.getData()
            self.connected = true
        }
    }
    
    func getData() -> Data? {
        let json: JSON = JSON(url: "https://dl.dropboxusercontent.com/u/56017856/dates.json")
        return json.load()
    }
    
    func load(_ date: Date) {
        self.calendar.isHidden = true
        self.blurView.isHidden = true
        self.ab.isHidden = false
        self.another.isHidden = false
        
        // Make date readable; display it
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        let strDate: String = dateFormatter.string(from: date)
        self.dateString.text = strDate
        
        if let req = self.request {
            let data = JSON.parse(req)
            
            dateFormatter.dateStyle = .short
            let keyArr: [String] = dateFormatter.string(from: date).components(separatedBy: "/")
            let keyStr: String = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
            
            if let maxDate: String = data.value(forKey: "maxDate") as? String {
                self.calendar.maximumDate = dateFormatter.date(from: maxDate)
            }
            
            if let abDay: String = data.value(forKey: keyStr) as? String {
                if abDay == "PD" {
                    self.ab.font = UIFont.systemFont(ofSize: 25)
                    self.ab.numberOfLines = 2 // Add a line to fit the following
                    self.ab.text = "Professional Development Day\n(No School)"
                    self.circleView.isHidden = true
                } else {
                    self.ab.font = UIFont.systemFont(ofSize: 132)
                    self.ab.numberOfLines = 1
                    self.ab.text = abDay
                    self.circleView.isHidden = false
                }
            } else {
                self.ab.font = UIFont.systemFont(ofSize: 50)
                self.ab.text = "No School"
                self.circleView.isHidden = true
            }
        } else {
            self.connected = false
        }
    }
    
    func getDay(_ date: Date) -> String? {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let keyArr: [String] = dateFormatter.string(from: date).components(separatedBy: "/")
        let keyStr: String = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
        if let req = self.request {
            let data = JSON.parse(req)
            if let dateString: String = data.value(forKey: keyStr) as? String {
                return dateString
            } else {
                return "No School"
            }
        }
        return nil
    }
    
    func searchNext(_ type: String, withCal cal: Calendar) -> Date {
        var dayType: String = ""
        var tempDay: Date = Date()
        while(dayType != type) {
            tempDay = cal.date(byAdding: .day, value: 1, to: tempDay)!
            if let nextDay: String = self.getDay(tempDay) {
                dayType = nextDay
            }
        }
        return tempDay
    }
    
    func getNext(_ type: String) {
        let today: Date = Date()
        let cal: Calendar = Calendar(identifier: .gregorian)
        var newDate: Date?
        switch type {
        case "tomorrow":
            newDate = cal.date(byAdding: .day, value: 1, to: today)
            if let tom: Date = newDate {
                self.load(tom)
            } else {
                print("Tomorrow not a valid date")
            }
        case "aday":
            newDate = self.searchNext("A", withCal: cal)
            if let aDay: Date = newDate {
                self.load(aDay)
            }
        case "bday":
            newDate = self.searchNext("B", withCal: cal)
            if let bDay: Date = newDate {
                self.load(bDay)
            }
        default:
            print("3D Touch command unrecognized")
        }
        
        if let nextDay: Date = newDate {
            self.calendar.date = nextDay // Update calendar date so reload works properly
        }
    }
    
    func configCircle() {
        self.circleView.layer.zPosition = -1 // Put circle view behind day type
        self.circleView.layer.cornerRadius = 79  // Half of width
    }
    
    func configButtons() {
        self.reload.layer.cornerRadius = 29.5
        self.another.layer.cornerRadius = 29.5
    }
}
