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
        self.reload.setTitle("Reload", for: UIControlState())
        
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
            self.ab.isHidden = true
            
            self.another.setTitle("Today", for: UIControlState())
            self.reload.setTitle("Load", for: UIControlState())
            
            self.today = true
        }
    }
    
    @IBAction func refresh() {
        self.reload.setTitle("Reload", for: UIControlState())
        self.another.setTitle("Another Date?", for: UIControlState())
        
        if self.connected {
            self.load(calendar.date)
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
        self.ab.isHidden = false
        self.another.isHidden = false
        
        // Make date readable; display it
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        let strDate = dateFormatter.string(from: date)
        self.dateString.text = strDate
        
        if let req = self.request {
            let data = JSON.parse(req)
            
            dateFormatter.dateStyle = .short
            let keyArr: [String] = dateFormatter.string(from: date).components(separatedBy: "/")
            let keyStr = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
            
            if let maxDate: String = data.value(forKey: "maxDate") as? String {
                self.calendar.maximumDate = dateFormatter.date(from: maxDate)
            }
            
            if let abDay: String = data.value(forKey: keyStr) as? String {
                if abDay == "PD" {
                    self.ab.font = UIFont.systemFont(ofSize: 20)
                    self.ab.numberOfLines = 2 // Add a line to fit the following
                    self.ab.text = "Professional Development Day\n(No School)"
                } else {
                    self.ab.font = UIFont.systemFont(ofSize: 100)
                    self.ab.numberOfLines = 1
                    self.ab.text = abDay
                }
            } else {
                self.ab.font = UIFont.systemFont(ofSize: 20)
                self.ab.text = "No School"
            }
        } else {
            self.connected = false
        }
        return nil
    }
    
    func getNext(_ type: String) {
        let today: Date = Date()
        let cal: Calendar = Calendar(identifier: .gregorian)
        switch type {
        case "tomorrow":
            if let tom: Date = cal.date(byAdding: .day, value: 1, to: today) {
                self.load(tom)
            } else {
                print("Tomorrow not a valid date")
            }
        case "aday":
            var dayType: String = ""
            var tempDay: Date = today
            while(dayType != "A") {
                if let nextDay: String = self.load(tempDay) {
                    dayType = nextDay
                }
                tempDay = cal.date(byAdding: .day, value: 1, to: tempDay)!
            }
            self.load(tempDay)
        case "bday":
            var dayType: String = ""
            var tempDay: Date = today
            while(dayType != "B") {
                if let nextDay: String = self.load(tempDay) {
                    dayType = nextDay
                }
                tempDay = cal.date(byAdding: .day, value: 1, to: tempDay)!
                print("\(tempDay): \(dayType)")
            }
            self.load(tempDay)
        default:
            print("3D Touch command unrecognized")
        }
    }
}
