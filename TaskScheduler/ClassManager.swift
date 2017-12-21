//
//  ClassManager.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 12/8/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import os.log


class ClassManager{
    //static var instance : ClassManager!
    struct PropertyKey {
        static let classIDCounter = "classIDCounter"
        static let taskIDCounter = "taskIDCounter"
        static let classes = "classes"
    }
    
    static var sharedInstance = ClassManager()
    private init() {}
    var classIDCounter = 0
    var taskIDCounter = 0
    var classes = [Class] ()
    
    init(classIDCounter:Int, taskIDCounter:Int, classes: [Class]) {
        self.classIDCounter = classIDCounter
        self.taskIDCounter = taskIDCounter
        self.classes = classes
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(classIDCounter, forKey: PropertyKey.classIDCounter)
        aCoder.encode(taskIDCounter, forKey: PropertyKey.taskIDCounter)
        aCoder.encode(classes, forKey: PropertyKey.classes)
        
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let classIDCounter = aDecoder.decodeInteger(forKey: PropertyKey.classIDCounter)
        let taskIDCounter = aDecoder.decodeInteger(forKey: PropertyKey.taskIDCounter)
        guard let classes = aDecoder.decodeObject(forKey: PropertyKey.classes) as? [Class] else {
            os_log("Unable to decode the classes for a class manager.", log: OSLog.default, type: .debug)
            return nil
            }
        self.init(classIDCounter: classIDCounter, taskIDCounter: taskIDCounter, classes: classes)
        
    }
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("classManager")
    
    public func saveClassManager(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(ClassManager.sharedInstance, toFile: ClassManager.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("ClassManager successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save ClassManager...", log: OSLog.default, type: .error)
        }
    }
    
    public func getAllTasks()-> ([Task]){
        var tasks = [Task]()
        for class1 in classes{
            let task1 = class1.getTasks()
            tasks.append(contentsOf: task1)
        }
        return tasks
    }
    
    public func updateTask(task:Task) -> (){
        let class1 = task.getClass()
        for class2 in classes{
            if(class2.getId() == class1.getId()){
                var tasks = class2.getTasks()
                for i in 0..<tasks.count{
                    if (tasks[i].getId() == task.getId()){
                        tasks[i] = task
                    }
                }
            }
        }
    }
    
    public func updateClass (class1: Class){
        for i in 0..<classes.count{
            if (classes[i].getId() == class1.getId()){
                classes[i] = class1
            }
        }
    }
    
    public func addClass (class1:Class){
        classes.append(class1)
    }
    
    public func removeClass (class1:Class){
        for i in 0..<classes.count{
            if (classes[i].getId() == class1.getId()){
                classes.remove(at: i)
            }
        }
    }
    
    public func addTask(task:Task){
        let class1 = task.getClass()
        for i in 0..<classes.count{
            if (classes[i].getId() == class1.getId()){
                classes[i].addTask(task: task)
            }
        }
    }
    
    public func removeTask(task:Task){
        let class1 = task.getClass()
        for i in 0..<classes.count{
            if (classes[i].getId() == class1.getId()){
                let tasks = class1.getTasks()
                
                for j in 0..<tasks.count{
                    if (tasks[j].getId() == task.getId()){
                        class1.removeTaskAt(index: i)
                    }
                }
                
            }
        }
    }
    
    public func generateNewClassID () -> Int{
        classIDCounter += 1
        return classIDCounter
    }
    
    public func generateNewTaskID() -> Int{
        taskIDCounter += 1
        return taskIDCounter
    }
    
//    init(dict: Dictionary<String, AnyObject>) {
//        guard let classIDCounter = dict[PropertyKey.classIDCounter] as? Int else{
//            print("Unable to decode classIDcounter in ClassManager")
//            return
//        }
//        
//        guard let taskIDCounter = dict[PropertyKey.taskIDCounter] as? Int else{
//            print("Unable to decode taskIDcounter in ClassManager")
//            return
//        }
//        guard let classesDictionary = dict[PropertyKey.classes] as? Array<Dictionary<String,AnyObject>> else{
//            print("Unable to decode classes in ClassManager")
//            return
//        }
//        
//        self.classIDCounter = classIDCounter
//        self.taskIDCounter = taskIDCounter
//        self.classes = [Class]()
//        for class1 in classesDictionary {
//            classes.append(Class(dict:class1))
//        }
//    }
//    
//    public func toDict () -> Dictionary<String, AnyObject>{
//        var array = [Dictionary<String, AnyObject>] ()
//        for class1 in classes{
//            array.append(class1.toDict())
//        }
//        
//        return [PropertyKey.classIDCounter: classIDCounter as AnyObject,
//                PropertyKey.taskIDCounter: taskIDCounter as AnyObject,
//                PropertyKey.classes: classes as AnyObject]
//    }
//   
//    public func saveData(){
//        do{
//            try Locksmith.saveData(data: ["ClassManager":ClassManager.sharedInstance], forUserAccount: "TaskScheduler")
//        } catch{
//            
//        }
//    }
//    
//    public func LoadData(){
//        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "TaskScheduler")! as Dictionary<String,AnyObject>
//        ClassManager.sharedInstance = (dictionary["ClassManager"] as? ClassManager)!
//    }
}
