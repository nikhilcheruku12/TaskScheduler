//
//  Class.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/7/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation

class Class{
    var name: String;
    var importance: Float;
    
    init?(name: String, importance: Float) {
        self.name = name;
        self.importance = importance;
        
        if name.isEmpty || importance < 0  {
            return nil
        }
    }
}
