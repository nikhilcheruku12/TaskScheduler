//
//  SchedulingAlgorithm.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 8/30/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import EventKit
class SchedulingAlgorithm {
    var ekCalendar: EKCalendar!
    var events: [EKEvent]?
    private let eventStore = EKEventStore()
    var tasks: [Task]?
    var virtualCalendar = [availability]()
    var pq = PriorityQueue<Task>(ascending: false)
    enum availability {
        case empty
        case scheduled
        case existed
    }
    
    
    
    init?(tasks: [Task]?){
        requestAccessToCalendar()
        self.tasks = tasks
        
    }
    
    func initializeVirtualCal(){
        var latestDateDue = Date()
        if self.tasks != nil{
            for t in self.tasks!{
                self.assignWeightToTask(task: t)
                pq.push(t) //add task to queue
                let tempDate = t.dueDate
                if latestDateDue < tempDate{
                    latestDateDue = tempDate
                }
            }
        }
        print("latest \(latestDateDue) " )
        loadEvents(endDate: latestDateDue)
        while pq.count != 0{
            if let t = pq.pop(){
                print("_______________")
                print(t.name)
                print(t.dueDate)
                print(t.weight)
                print(t.startDate)
                print("_______________")
            }
        }
    }
    func assignWeightToTask(task: Task){
        
        let reward = 100 * (((0.6) * (task.percentage / 100)) + ((0.4) * (task.class1.importance / 10)))
        let weight = Float(reward * reward) / Float(task.duration)
        task.weight = weight
        
    }
    
    //load all user's events between current date and latest dueDate
    func loadEvents(endDate: Date) {
        let currentDate = Date()
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: currentDate, end: endDate, calendars: nil)
        
        // Use the configured NSPredicate to find and return events in the store that match
        self.events = eventStore.events(matching: eventsPredicate).sorted(){
            (e1: EKEvent, e2: EKEvent) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
        if self.events != nil{
            print(events!.count)
            for e in self.events!{
                print(e.title)
            }
        }
    }
    
    func loadPriorityQueue(){
        
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted {
                print("access granted")
            } else {
                print("access not granted")
            }
        })
    }
    
    
    
    
    //use it later
    func updateCalendar(){
        
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run\
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            print("permission to the calendar granted")
            
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            print("we need your permission to the calendar")
        }
        
    }
    
}
