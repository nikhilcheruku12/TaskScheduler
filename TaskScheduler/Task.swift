//
//  Task.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/17/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import os.log

class Task: NSObject, NSCoding{
    struct PropertyKey {
        static let name = "name"
        static let percentage = "percentage"
        static let class1 = "class1"
        static let duration = "duration"
        static let dueDate = "dueDate"
    }
    
    var name: String;
    var percentage: Float;
    var class1: Class;
    var duration: Float;
    var dueDate: Date;

    
    init?(name: String, percentage: Float, class1:Class, duration:Float, dueDate:Date) {
        self.name = name;
        self.percentage = percentage;
        self.class1 = class1;
        self.duration = duration;
        self.dueDate = dueDate;
        if name.isEmpty || percentage < 0   {
            return nil
        }
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(percentage, forKey: PropertyKey.percentage)
        aCoder.encode(class1,forKey: PropertyKey.class1 )
        aCoder.encode(duration,forKey: PropertyKey.duration)
        aCoder.encode(dueDate,forKey: PropertyKey.dueDate)
    }
    
   public required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let percentage = aDecoder.decodeFloat(forKey: PropertyKey.percentage)
        
        guard let class1 = aDecoder.decodeObject(forKey: PropertyKey.class1) as? Class else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let duration = aDecoder.decodeFloat(forKey: PropertyKey.duration)
        
        guard let dueDate = aDecoder.decodeObject(forKey: PropertyKey.dueDate) as? Date else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        // Must call designated initializer.
        /*if(percentage == nil){
         print("percentage is nil")
         percentage = 10.0
         }*/
        
        self.init(name: name, percentage: percentage,  class1:class1, duration:duration, dueDate:dueDate)
        
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tasks")
    
}
