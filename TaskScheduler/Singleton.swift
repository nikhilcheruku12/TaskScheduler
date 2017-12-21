//
//  Singleton.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 10/13/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import os.log
class Singleton: NSObject, NSCoding{
    struct PropertyKey {
        static let sleepTime = "sleepTime"
        static let wakeUpTime = "wakeUpTime"
        static let lunchTime = "lunchTime"
        static let dinnerTime = "dinnerTime"
        static let hoursToEat = "hoursToEat"
        static let focusTime = "focusTime"
        static let pqTasks = "pqTasks"
        static let classIDCounter = "classIDCounter"
        static let taskIDCounter = "taskIDCounter"
    }
    
    static let sharedSingleton = Singleton()
    private override init() {}
    init(sleepTime: Int, wakeUpTime: Int, lunchTime: Int, dinnerTime: Int, hoursToEat: Int, focusTime: Int, pqTasks: [Task],classIDCounter:Int, taskIDCounter:Int){
        self.sleepTime = sleepTime
        self.wakeUpTime = wakeUpTime
        self.lunchTime = lunchTime
        self.dinnerTime = dinnerTime
        self.hoursToEat = hoursToEat
        self.focusTime = focusTime
        self.pqTasks = pqTasks
        self.classIDCounter = classIDCounter
        self.taskIDCounter = taskIDCounter
    }
    var sleepTime = -1
    var wakeUpTime  = -1
    var lunchTime = -1
    var dinnerTime = -1
    var hoursToEat = -1
    var focusTime = -1
    var pqTasks = [Task]()
    var classIDCounter = 0
    var taskIDCounter = 0
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sleepTime, forKey: PropertyKey.sleepTime)
        aCoder.encode(wakeUpTime, forKey: PropertyKey.wakeUpTime)
        aCoder.encode(lunchTime, forKey: PropertyKey.lunchTime)
        aCoder.encode(dinnerTime, forKey: PropertyKey.dinnerTime)
        aCoder.encode(hoursToEat, forKey: PropertyKey.hoursToEat)
        aCoder.encode(focusTime, forKey: PropertyKey.focusTime)
        aCoder.encode(pqTasks, forKey: PropertyKey.pqTasks)
        aCoder.encode(classIDCounter, forKey: PropertyKey.classIDCounter)
        aCoder.encode(taskIDCounter, forKey: PropertyKey.taskIDCounter)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let sleepTime = aDecoder.decodeInteger(forKey: PropertyKey.sleepTime)
        let wakeUpTime = aDecoder.decodeInteger(forKey: PropertyKey.wakeUpTime)
        let lunchTime = aDecoder.decodeInteger(forKey: PropertyKey.lunchTime)
        let dinnerTime = aDecoder.decodeInteger(forKey: PropertyKey.dinnerTime)
        let hoursToEat = aDecoder.decodeInteger(forKey: PropertyKey.hoursToEat)
        let focusTime = aDecoder.decodeInteger(forKey: PropertyKey.focusTime)
        guard let pqTasks = aDecoder.decodeObject(forKey: PropertyKey.pqTasks) as? [Task] else {
            os_log("Unable to decode the pqTasks for a singleton object.", log: OSLog.default, type: .debug)
            return nil
        }
        let classIDCounter = aDecoder.decodeInteger(forKey: PropertyKey.classIDCounter)
        let taskIDCounter = aDecoder.decodeInteger(forKey: PropertyKey.taskIDCounter)
        self.init(sleepTime: sleepTime, wakeUpTime: wakeUpTime, lunchTime: lunchTime, dinnerTime: dinnerTime, hoursToEat: hoursToEat, focusTime: focusTime, pqTasks: pqTasks, classIDCounter: classIDCounter, taskIDCounter: taskIDCounter)
    }
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("singleton")
    
    static func saveSingleton(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(Singleton.sharedSingleton, toFile: Singleton.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Singleton successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save singleton...", log: OSLog.default, type: .error)
        }
    }
    
    public func generateNewClassID () -> Int{
        classIDCounter += 1
        Singleton.saveSingleton()
        print("generate new class ID \(classIDCounter)")
        return classIDCounter

    }
    
    public func generateNewTaskID() -> Int{
        taskIDCounter += 1
        Singleton.saveSingleton()
        print("generate new task ID \(taskIDCounter)")
        return taskIDCounter
    }
}

