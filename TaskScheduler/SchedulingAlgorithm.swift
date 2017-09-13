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
    private let eventStore = EKEventStore()
    let calendars : [EKCalendar]
    var events: [EKEvent]?
    var tasks: [Task]?
    var virtualCalendar = [VirtualInterval]()
    var pq = PriorityQueue<Task>(ascending: false)
    var latestDateDue: Date?
    
    struct VirtualInterval {
        var startDate: Date
        var endDate : Date
        var status: String
    }
    var sleepTime = 23
    var wakeUpTime = 8
    
    init?(tasks: [Task]?){
        calendars = eventStore.calendars(for: EKEntityType.event)
        self.tasks = tasks
        initialVirtualCalAndAssignTasksToPQ()
        requestAccessToCalendar()
    }
    
    
    
    
    //initialize array of interval struct with X number of haldHours between current and lastest due date
    //assign weight to tasks and out tasks in pq
    func initialVirtualCalAndAssignTasksToPQ(){
        self.latestDateDue = Date()
        //find latest due date and push all tasks due in future into the pq
        //truncate current Date up to the whole hour date
        var currentDate = Date()
        let timeIntervalCurrent = floor(currentDate .timeIntervalSinceReferenceDate / 3600.0) * 3600.0
        currentDate = Date(timeIntervalSinceReferenceDate: timeIntervalCurrent+3600)
        if self.tasks != nil{
            for t in self.tasks!{
                if(currentDate < t.dueDate){
                    Task.assignWeightToTask(task: t)
                    pq.push(t) //add task to queue
                    let tempDate = t.dueDate
                    if self.latestDateDue! < tempDate{
                        self.latestDateDue = tempDate
                    }
                }else{
                    //task already dued
                }
            }
        }
        //truncate latest duedate down
        let timeIntervalLatest = floor((latestDateDue? .timeIntervalSinceReferenceDate)! / 3600.0) * 3600.0
        self.latestDateDue = Date(timeIntervalSinceReferenceDate: timeIntervalLatest)
        
        let halfHoursBtwCurrentDateAndLatestDate = Int(self.latestDateDue!.timeIntervalSince(currentDate))/1800

        for i in 0..<halfHoursBtwCurrentDateAndLatestDate{
            let timeBegin = Date(timeInterval: (TimeInterval(i * 1800)), since: currentDate)
            let timeEnd = Date(timeInterval: (TimeInterval(1800)), since: timeBegin)
            
            var interval: VirtualInterval
            let currentIntervalBegin = Calendar.current.component(.hour, from: timeBegin)
            let currentIntervalEnd = Calendar.current.component(.hour, from: timeEnd)
            //put default sleeping time in vCal
            if (currentIntervalBegin >= sleepTime || currentIntervalBegin < wakeUpTime)
                && (currentIntervalEnd >= sleepTime || currentIntervalEnd <= wakeUpTime)  {
                interval = VirtualInterval(startDate: timeBegin, endDate: timeEnd, status: "sleep")
            } else {
                interval = VirtualInterval(startDate: timeBegin, endDate: timeEnd, status: "empty")
            }
            virtualCalendar.append(interval)
        }
        print("number of intervals: " + String(virtualCalendar.count))
        print(Date())

    }
    
    
    
    func createVirtualCal(){
        //put task in vCal
        //frontLoad tasks
        if self.latestDateDue != nil{
            loadUserEvents(endDate: self.latestDateDue!)
            while pq.count != 0{
                if let t = pq.pop(){
                    print("_______________")
                    print("name: ")
                    print(t.name)
                    print("dueDate: ")
                    print(t.dueDate)
                    print("weight: ")
                    print(t.weight)
                    print("startDate: ")
                    print(t.startDate)
                    print("_______________")
                    //writeEventToCalendar(firstTask: t)
                }
            }
        }
        var temp = 0
        for i in virtualCalendar{
            print(temp)
            print("Start : \(i.startDate)")
            print("End :  \(i.endDate)")
            print("Status :  \(i.status)")
            temp += 1
        }
    }
    
    
    
    //load all user's events between current date and latest dueDate
    func loadUserEvents(endDate: Date) {
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
            //put users events in vCal
            for e in self.events!{
                print(e.title)
                for i in 0..<virtualCalendar.count{
                    if (virtualCalendar[i].startDate <= e.startDate &&
                        e.startDate < virtualCalendar[i].endDate) ||
                       (e.startDate <= virtualCalendar[i].startDate &&
                        virtualCalendar[i].endDate <= e.endDate) ||
                       (virtualCalendar[i].startDate < e.endDate &&
                            e.endDate <= virtualCalendar[i].endDate)
                    {
                        
                        virtualCalendar[i].status = "users"
                        
                        
                    }
                }
               
            }
        }
    }
    
    //delete event based on its predicate (start, end dates)
    func deleteEventFromCalendar(eventID: String){
        for cal in self.calendars {
            if cal.title == "Calendar"{

                // Save the calendar using the Event Store instance
                
              
            }
        }

    }
    
    func writeEventToCalendar(firstTask: Task) {
        for cal in self.calendars {
            // 2
            if cal.title == "Calendar"{
                let newEvent = EKEvent(eventStore: eventStore)
                newEvent.calendar = cal
                newEvent.title = firstTask.name
                newEvent.startDate = firstTask.startDate
                newEvent.endDate = firstTask.dueDate
                
            // Save the calendar using the Event Store instance
            
                do {
                    try eventStore.save(newEvent, span: .thisEvent, commit: true)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
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
