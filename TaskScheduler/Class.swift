//
//  Class.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/7/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import os.log

class Class: NSObject, NSCoding{
    struct PropertyKey {
        static let name = "name"
        static let importance = "importance"
        static let taskKey = "task"
        static let colorNumber = "colorNumber"
        static let id = "id"
    }
    
    private var name: String
    private var importance: Float
    private var tasks: [Task]
    private var colorNumber : Float
    private var id: Int
    public func getName()-> String{
        return name
    }
    
    public func setName(name:String){
        self.name = name
        ClassManager.sharedInstance.updateClass(class1: self)
    }
    
    public func setImportance(importance: Float){
        self.importance = importance
        ClassManager.sharedInstance.updateClass(class1: self)
    }
    
    public func getImportance() -> Float{
        return importance
    }
    
    public func getTasks()-> [Task]{
        return self.tasks
    }
    
    public func setTasks(tasks: [Task]){
        self.tasks = tasks
        ClassManager.sharedInstance.updateClass(class1: self)
    }
    
    public func getColorNumber() -> Float {
        return colorNumber
    }
    public func setColorNumber(colorNumber : Float) {
        self.colorNumber = colorNumber
        ClassManager.sharedInstance.updateClass(class1: self)
    }
    
    public func getId()-> Int{
        return self.id
    }
    
    public func removeTaskAt(index:Int){
        if(index < tasks.count){
            tasks.remove(at: index)
        }
    }
    
    init?(name: String, importance: Float, colorNumber: Float, id:Int) {
        self.name = name;
        self.importance = importance;
        self.tasks = [Task]()
        self.colorNumber = colorNumber;
        self.id = id
        if name.isEmpty || importance < 0  {
            return nil
        }
    }
    
    init?(name: String, importance: Float, tasks: [Task], colorNumber: Float, id: Int) {
        self.name = name;
        self.importance = importance;
        self.tasks = tasks
        self.colorNumber = colorNumber;
        self.id = id
        if name.isEmpty || importance < 0  {
            return nil
        }
    }
    
//    init(dict: Dictionary<String,AnyObject>) {
//        guard let name = dict[PropertyKey.name] as? String else{
//            print("Unable to decode name for class")
//        }
//
//        guard let id = dict[PropertyKey.id] as? Int else{
//            print("Unable to decode id for class")
//        }
//
//        guard let tasks = dict[PropertyKey.taskKey] as? [Task] else{
//            print("Unable to decode name for class")
//        }
//
//        guard let colorNumber = dict[PropertyKey.colorNumber] as? Float else{
//            print("unable to decode color number")
//        }
//
//        guard let importance = dict[PropertyKey.importance] as? Float else{
//            print("unable to decode importance ")
//        }
//
//        self.name = name
//        self.id = id
//        self.tasks = tasks
//        self.colorNumber = colorNumber
//        self.importance = importance
//    }
//
//    public func toDict () -> Dictionary<String,AnyObject>{
//        return [PropertyKey.name : name as AnyObject,
//                PropertyKey.id : id as AnyObject,
//                PropertyKey.taskKey: tasks as AnyObject,
//                PropertyKey.colorNumber: colorNumber as AnyObject,
//                PropertyKey.importance: importance as AnyObject]
//    }
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(importance, forKey: PropertyKey.importance)
        aCoder.encode(tasks, forKey:PropertyKey.taskKey)
        aCoder.encode(colorNumber, forKey: PropertyKey.colorNumber)
        aCoder.encode(id, forKey: PropertyKey.id)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a class object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let importance = aDecoder.decodeFloat(forKey: PropertyKey.importance)
        
        let colorNumber = aDecoder.decodeFloat(forKey: PropertyKey.colorNumber)
        
        guard let tasks = aDecoder.decodeObject(forKey: PropertyKey.taskKey) as? [Task] else{
            os_log("Unable to decode tasks for Class Object", log: OSLog.default, type: .debug)
            return nil
        }
        
       let id = aDecoder.decodeInt32(forKey: PropertyKey.id)
        
        self.init(name: name, importance: importance, tasks: tasks, colorNumber : colorNumber,id: Int(id) )
        
    }
    
    func addTask (task: Task){
        tasks.append(task)
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("classes")
    
}

