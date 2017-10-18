//
//  Singleton.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 10/13/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
class Singleton{
    static let sharedSingleton = Singleton()
    private init() {}
    var sleepTime = -1
    var wakeUpTime  = -1
    var lunchTime = -1
    var dinnerTime = -1
    var hoursToEat = -1
}
