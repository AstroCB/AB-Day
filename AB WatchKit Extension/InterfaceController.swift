//
//  InterfaceController.swift
//  AB WatchKit Extension
//
//  Created by Cameron Bernhardt on 4/3/15.
//  Copyright (c) 2015 Cameron Bernhardt. All rights reserved.
//

import WatchKit
import Foundation

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

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var day: WKInterfaceLabel!
    @IBOutlet var later: WKInterfaceButton!
    
    var data: Data?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        self.initConfig()
    }
    
    public func initConfig() {
        self.setLabelText("-", withSize: 100) // Initialize label
        
        if let abDay: String = getDay(forDate: Date()) {
            if abDay != "failed" {
                self.setLabelText(abDay, withSize: 90)
            }
        } else {
            self.setLabelText("No School", withSize: 15)
        }
        let json: JSON = JSON(url: "https://api.myjson.com/bins/1j05q")
        data = json.load()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if segueIdentifier == "toWeekView" {
            var daysDict: [String: String] = [String: String]()
            
            for i in 1 ..< 6 { // Get next five days
                // Day from reference point (1..5)
                var dayComponent: DateComponents = DateComponents()
                dayComponent.day = i;
                
                let cal: Calendar = Calendar.current
                
                if let nextDate: Date = cal.date(byAdding: dayComponent, to: Date()) {
                    // Formatted date
                    let formatter: DateFormatter = DateFormatter()
                    formatter.dateStyle = DateFormatter.Style.short
                    
                    let dayString: String = formatter.string(from: nextDate) // Short date string for cell
                    
                    // Day value
                    if let dayType: String = getDay(forDate: nextDate) {
                        if dayType != "failed" {
                            // Add to dictionary
                            daysDict[dayString] = dayType
                        }
                    } else {
                        // Add to dictionary (no school)
                        daysDict[dayString] = "No School"
                    }
                }
            }
            return daysDict
        }
        return nil
    }
    
    func setLabelText(_ text: String, withSize size: CGFloat) {
        let font: UIFont = UIFont.systemFont(ofSize: size)
        let attrString: NSAttributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        self.day.setAttributedText(attrString)
    }
    
    public func getDay(forDate date: Date) -> String? {
        if let jData: Data = self.data {
            let newData: NSDictionary = JSON.parse(jData)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let keyArr: [String] = dateFormatter.string(from: date).components(separatedBy: "/")
            
            let keyStr: String = "\(keyArr[0] + keyArr[1])20\(keyArr[2])"
            return newData.value(forKey: keyStr) as? String
            
        }
        return "failed"
    }
}
