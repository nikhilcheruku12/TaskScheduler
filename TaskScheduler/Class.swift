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
    }
    
    var name: String
    var importance: Float
    var tasks: [Task]
    
    init?(name: String, importance: Float) {
        self.name = name;
        self.importance = importance;
        self.tasks = [Task]()
        
        if name.isEmpty || importance < 0  {
            return nil
        }
    }
    
    init?(name: String, importance: Float, tasks: [Task]) {
        self.name = name;
        self.importance = importance;
        self.tasks = tasks
        if name.isEmpty || importance < 0  {
            return nil
        }
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(importance, forKey: PropertyKey.importance)
        aCoder.encode(tasks, forKey:PropertyKey.taskKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a class object.", log: OSLog.default, type: .debug)
            return nil
        }
        
         let importance = aDecoder.decodeFloat(forKey: PropertyKey.importance) 
        
       guard let tasks = aDecoder.decodeObject(forKey: PropertyKey.taskKey) as? [Task] else{
            os_log("Unable to decode tasks for Class Object", log: OSLog.default, type: .debug)
            return nil
        }
        

        self.init(name: name, importance: importance, tasks: tasks)
        
    }
    
    func addTask (task: Task){
        tasks.append(task)
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("classes")
    
}
