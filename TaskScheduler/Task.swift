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
        //static let completeStatus = "completeStatus"
        static let percentageFinished = "percentageFinished"
        static let id = "id"
    }
    
    
    private var name: String
    private var duration: Float
    private var percentage: Float
    private var dueDate: Date
    private var earliestStartDate : Date
    
    private var class1: Class
    private var daysBeforeToStart: Int?
    private var startDate: Date
    private var weight : Float
    private var id : Int
    //private var completeStatus: Bool
    
    private var percentageFinished: Float
    
    public func getPercentageFinished () -> Float{
        return percentageFinished
    }
    
    public func setPercentageFinished(percentageFinished: Float) -> (){
        self.percentageFinished = percentageFinished
        ClassManager.sharedInstance.updateTask(task: self)
    }
    
    public func getName ()-> String{
        return name
    }
    
    public func setName (name: String){
        self.name = name
        ClassManager.sharedInstance.updateTask(task: self)
        //ClassManager.sh
    }
    
    public func getDuration () -> Float{
        return duration
    }
    public func setDuration(duration: Float){
        self.duration = duration
        ClassManager.sharedInstance.updateTask(task: self)
    }
    public func getPercentage () -> Float{
        return percentage
    }
    public func setPercentage(percentage: Float){
        self.percentage = percentage
        ClassManager.sharedInstance.updateTask(task: self)
    }
    
    public func getDueDate() -> Date{
        return dueDate
    }
    public func setDueDate(date : Date){
        self.dueDate = date
        ClassManager.sharedInstance.updateTask(task: self)
    }
    
    public func getEarliestStartDate() -> Date{
        return earliestStartDate
    }
    public func setEarliestStartDate(earliestStartDate : Date){
        self.earliestStartDate = earliestStartDate
        ClassManager.sharedInstance.updateTask(task: self)
    }
    
    public func getId ()-> Int{
        return self.id
    }
    
    public func toDict() -> Dictionary<String,AnyObject>{
        return [PropertyKey.name: getName() as AnyObject ,
                PropertyKey.percentage: getPercentage() as AnyObject,
                PropertyKey.class1: getClass() as AnyObject,
                PropertyKey.duration: getDuration() as AnyObject,
                PropertyKey.dueDate: getDueDate() as AnyObject,
                PropertyKey.daysBeforeToStart: daysBeforeToStart as AnyObject,
                PropertyKey.weight: weight as AnyObject,
                PropertyKey.earliestStartDate: earliestStartDate as AnyObject,
                PropertyKey.percentageFinished: percentageFinished as AnyObject,
                PropertyKey.id: id as AnyObject ]
    }
    
//    init(dict: Dictionary<String, AnyObject>) {
//        guard let name = dict[PropertyKey.name] as? String else{
//            print("unable to decode name in task")
//        }
//        
//        guard let percenatge = dict[PropertyKey.percentage] as? Float else{
//            print("unable to decode percentage in task")
//        }
//        guard let class1 = dict[PropertyKey.class1] as? Class else {
//            print("unable to decode class in task")
//        
//        }
//        
//        guard let duration = dict[PropertyKey.duration] as? Float else{
//            print("unable to save duration")
//        }
//        
//        guard let dueDate = dict[PropertyKey.dueDate] as? Date else {
//            print("Unable to decode dueDate for a task object.")
//        }
//        
//        guard let daysBeforeToStart = dict[PropertyKey.daysBeforeToStart] as? Int else {
//            print("Unable to decode daysBeforeToStart for a task object.")
//        }
//        guard let weight = dict[PropertyKey.weight] as? Float else{
//            print("unable to save duration")
//        }
//        
//        guard let earliestStartDate = dict[PropertyKey.dueDate] as? Date else {
//            print("Unable to decode earliestStartTime for a task object.")
//        }
//        
//        guard let percentageFinished = dict[PropertyKey.percentageFinished] as? Float else{
//            print("Unable to decode earliestStartTime for a task object.")
//        }
//        
//        guard let id = dict[PropertyKey.id] as? Int else{
//            print("Unable to decode id for a task object.")
//        }
//        
//        self.name = name
//        self.id = id
//        self.percentageFinished = percentageFinished
//        self.percentage = percenatge
//        self.earliestStartDate = earliestStartDate
//        self.dueDate = dueDate
//        self.duration = duration
//        self.daysBeforeToStart = daysBeforeToStart
//        self.weight = weight
//        self.class1 = class1
//    }
//    
    init?(name: String, percentage: Float, class1:Class, duration:Float, dueDate:Date, earliestStartDate: Date, percentageFinished: Float, id: Int) {
        self.name = name;
        self.percentage = percentage;
        
        self.percentageFinished = percentageFinished ;
        
        self.class1 = class1;
        self.duration = duration;
        self.dueDate = dueDate;
        self.weight = 0.0
        //self.completeStatus = false
        // Truncate down to nearest half hour
        let timeInterval = floor(self.dueDate.timeIntervalSinceReferenceDate/60.0) * 60.0
        self.dueDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        self.earliestStartDate = earliestStartDate
        startDate = Date(timeInterval: TimeInterval(-duration*3600), since: dueDate)
        self.id = id
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
        //aCoder.encode(completeStatus, forKey: PropertyKey.completeStatus)
        
        aCoder.encode(percentageFinished, forKey: PropertyKey.percentageFinished)
        aCoder.encode(id, forKey: PropertyKey.id)
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
        
        let percentageFinished = aDecoder.decodeFloat(forKey: PropertyKey.percentageFinished)
        
        let id = aDecoder.decodeInt32(forKey: PropertyKey.id)
        //TODO
        //for daysBeforeToStart,startdate,weight declaration completeStatus
        
        // Must call designated initializer.
        /*if(percentage == nil){
         print("percentage is nil")
         percentage = 10.0
         }*/
        
        self.init(name: name, percentage: percentage,  class1:class1, duration:duration, dueDate:dueDate, earliestStartDate: earliestStartDate, percentageFinished: percentageFinished, id:Int(id))
        
    }
    
    /*
     * The heuristic function that assigns the weight to the task
     * The weight is calculated as 60% from the task's percentage, 40% from the importance,
     * and divided by the duration to normalize how much "benefit" each task provides per every hour.
     */
    
    static func assignWeightToTask(task: Task){
        
        let reward = 100 * (((0.6) * (task.percentage / 100)) + ((0.4) * (task.class1.getImportance() / 10)))
        let weight = Float(reward * reward) / Float(task.duration)
        task.weight = weight
        
    }
    
    /**** GETTERS/SETTERS *****/
    
    public func isComplete() -> Bool{
        return percentageFinished == 1.0
    }
    //    public func setComplete(completeStatus: Bool){
    //        self.completeStatus = completeStatus
    //    }
    
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
    public func getClass()->Class{
        return self.class1
    }
}

