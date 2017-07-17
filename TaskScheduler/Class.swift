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
    }
    
    var name: String;
    var importance: Float;
    
    init?(name: String, importance: Float) {
        self.name = name;
        self.importance = importance;
        
        if name.isEmpty || importance < 0  {
            return nil
        }
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(importance, forKey: PropertyKey.importance)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
         let importance = aDecoder.decodeFloat(forKey: PropertyKey.importance) 
        
        
        // Must call designated initializer.
        /*if(importance == nil){
            print("importance is nil")
             importance = 10.0
        }*/
       
        self.init(name: name, importance: importance)
        
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("classes")

}
