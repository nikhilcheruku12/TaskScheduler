//
//  Task.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/17/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import os.log

class Task: NSObject, NSCoding, Comparable{
    struct PropertyKey {
        static let name = "name"
        static let percentage = "percentage"
        static let class1 = "class1"
        static let duration = "duration"
        static let dueDate = "dueDate"
        static let daysBeforeToStart = "daysBeforeToStart"
        static let weight = "weight"
        static let earliestStartDate = "earliestStartDate"
        static let completeStatus = "completeStatus"
    }
    

    public var name: String
    public var duration: Float
    public var percentage: Float
    public var dueDate: Date
    public var earliestStartDate : Date?

    private var class1: Class
    private var daysBeforeToStart: Int?
    private var startDate: Date
    private var weight : Float
    private var completeStatus: Bool
    
    
    init?(name: String, percentage: Float, class1:Class, duration:Float, dueDate:Date, earliestStartDate: Date) {
        self.name = name;
        self.percentage = percentage;
        self.class1 = class1;
        self.duration = duration;
        self.dueDate = dueDate;
        self.weight = 0.0
        self.completeStatus = false
        // Truncate down to nearest half hour
        let timeInterval = floor(self.dueDate.timeIntervalSinceReferenceDate/60.0) * 60.0
        self.dueDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        self.earliestStartDate = earliestStartDate
        startDate = Date(timeInterval: TimeInterval(-duration*3600), since: dueDate)
        if name.isEmpty || percentage < 0   {
            return nil
        }
    }
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tasks")
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(percentage, forKey: PropertyKey.percentage)
        aCoder.encode(class1,forKey: PropertyKey.class1 )
        aCoder.encode(duration,forKey: PropertyKey.duration)
        aCoder.encode(dueDate,forKey: PropertyKey.dueDate)
        aCoder.encode(daysBeforeToStart,forKey: PropertyKey.daysBeforeToStart)
        aCoder.encode(weight,forKey: PropertyKey.weight)
        aCoder.encode(earliestStartDate, forKey: PropertyKey.earliestStartDate)
        aCoder.encode(completeStatus, forKey: PropertyKey.completeStatus)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a task object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let percentage = aDecoder.decodeFloat(forKey: PropertyKey.percentage)
        
        guard let class1 = aDecoder.decodeObject(forKey: PropertyKey.class1) as? Class else {
            os_log("Unable to decode class for a task object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let duration = aDecoder.decodeFloat(forKey: PropertyKey.duration)
        
        guard let dueDate = aDecoder.decodeObject(forKey: PropertyKey.dueDate) as? Date else {
            os_log("Unable to decode dueDate for a task object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let earliestStartDate = aDecoder.decodeObject(forKey: PropertyKey.earliestStartDate) as? Date else {
            os_log("Unable to decode earliestStartTime for a task object.", log: OSLog.default, type: .debug)
            return nil
        }
        //TODO
        //for daysBeforeToStart,startdate,weight declaration completeStatus
        
        // Must call designated initializer.
        /*if(percentage == nil){
         print("percentage is nil")
         percentage = 10.0
         }*/
        
        self.init(name: name, percentage: percentage,  class1:class1, duration:duration, dueDate:dueDate, earliestStartDate: earliestStartDate)
        
    }
    
    /*
     * The heuristic function that assigns the weight to the task
     * The weight is calculated as 60% from the task's percentage, 40% from the importance,
     * and divided by the duration to normalize how much "benefit" each task provides per every hour.
     */
    
    static func assignWeightToTask(task: Task){
        
        let reward = 100 * (((0.6) * (task.percentage / 100)) + ((0.4) * (task.class1.importance / 10)))
        let weight = Float(reward * reward) / Float(task.duration)
        task.weight = weight
        
    }
    
    /**** GETTERS/SETTERS *****/
    
    public func isComplete() -> Bool{
        return completeStatus
    }
    public func setComplete(completeStatus: Bool){
        self.completeStatus = completeStatus
    }
    
    /**** OPERATION OVERLOADING ****/
    
    // Comparator. Compares the due date, and then the weight, and finally the start date.
    static func < (lhs: Task, rhs: Task) -> Bool {
        if lhs.dueDate < rhs.dueDate{
            return false
        }
        else if  lhs.dueDate > rhs.dueDate{
            return true
        } else{
            if lhs.weight < rhs.weight {
                return true
            }
            else if lhs.weight > rhs.weight{
                return false
            }
            else{
                if lhs.startDate < rhs.startDate{
                    return false
                }
                else{
                    return true
                }
            }
        }
        
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        if (lhs.dueDate == rhs.dueDate) && (lhs.weight == rhs.weight) && (lhs.startDate == rhs.startDate) {
            return true
        }
        return false
    }
}
