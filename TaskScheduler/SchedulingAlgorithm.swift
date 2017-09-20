//
//  SchedulingAlgorithm.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 8/30/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import UIKit
import EventKit
class SchedulingAlgorithm {
    private var ekCalendar: EKCalendar!
    private let eventStore = EKEventStore()
    private var calendars : [EKCalendar]
    private var taskCalendar : EKCalendar
    private var events: [EKEvent]?
    private var tasks: [Task]?
    private var virtualCalendar = [VirtualInterval]()
    private var pq = PriorityQueue<Task>(ascending: false)
    private var latestDateDue: Date?
    
    struct VirtualInterval {
        var startDate: Date
        var endDate : Date
        var status: String
    }
    var sleepTime = 23
    var wakeUpTime = 8
    
    init?(tasks: [Task]?){
        taskCalendar = EKCalendar(for: .event, eventStore: eventStore)
        calendars = eventStore.calendars(for: EKEntityType.event)
        self.tasks = tasks
        initialVirtualCalAndAssignTasksToPQ()
        requestAccessToCalendar()
        createTaskCalendar()
    }
    
    public func schedule() -> String{
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
                    let success = addTaskToVirtualCalendar(task: t)
                    if !success {
                        //couldn't schedule task
                        return ("Failed to schedule " + t.name + " try to start the task earlier or reduce duration")
                    }
                    
                    //writeEventToCalendar(task: t)
                }
            }
        }
        
        scheduleToRealCalendar()
        return "Scheduled Succeed"
    }
    
    //delete tasks from currnet date to the lastest due date
    public func deleteTasksFromCalendar(){
        var arrayCal : [EKCalendar]?
        for cal in self.calendars {
            if cal.title == "ScheduledTaskCalendar"{
                arrayCal = [EKCalendar]()
                arrayCal?.append(cal)
                print(arrayCal!)
            }
        }
        if(arrayCal != nil) {
            let predicate = eventStore.predicateForEvents(withStart: Date(), end: self.latestDateDue!, calendars: arrayCal)
            let events = eventStore.events(matching: predicate) as [EKEvent]!
            if events != nil {
                for e in events!{
                    do {
                        try eventStore.remove(e, span: EKSpan.thisEvent, commit: true)
                    }catch let error {
                        print("Error removing event: ", error)
                    }
                }
            }
        } else {
            print("arrayCal is nil")
        }
        
        
    }
    
    
    public func printVirtualCalendar(){
        var temp = 0
        for i in virtualCalendar{
            print(temp)
            print("Start : \(i.startDate)")
            print("End :  \(i.endDate)")
            print("Status :  \(i.status)")
            temp += 1
        }
    }
    
    //*****PRIVATE FUNCTIONS******
    
    
    
    //create ScheduledTaskCalendar if it does not exist in user calendar app
    private func createTaskCalendar(){
        for cal in calendars{
            if cal.title == "ScheduledTaskCalendar" {
                print("ScheduledTaskCalendar already exist")
                return
            }
        }
        taskCalendar.title = "ScheduledTaskCalendar"
        // Access list of available sources from the Event Store
        // Filter the available sources and select the "iCloud" source to assign to the new calendar's, or "Local" if iCloud is not available
        let sourcesInEventStore = eventStore.sources
        let filteredEventStores = sourcesInEventStore.filter{
            (source: EKSource) -> Bool in
            source.sourceType.rawValue == EKSourceType.local.rawValue || source.title.lowercased().contains("icloud")
        }
        if filteredEventStores.count > 0 {
            taskCalendar.source = filteredEventStores.first!
        } else {
            taskCalendar.source = sourcesInEventStore.filter{
                (source: EKSource) -> Bool in
                source.sourceType.rawValue == EKSourceType.subscribed.rawValue
                }.first!
        }
    
        
        print("creating ScheduledTaskCalendar ")
        // Save the calendar using the Event Store instance
        do {
            try eventStore.saveCalendar(taskCalendar, commit: true)
            self.calendars = eventStore.calendars(for: .event)
            UserDefaults.standard.set(taskCalendar.calendarIdentifier, forKey: "TaskSchedulerPrimaryCalendar")
            print("create ScheduledTaskCalendar success ")
            for cal in self.calendars {
                print(cal.title)
            }
        } catch {
            let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            print("ScheduledTaskCalendar cannot be created \(error)")
        }
    }
    
    //initialize array of interval struct with X number of halfHours between current and lastest due date
    //assign weight to tasks and out tasks in pq
    private func initialVirtualCalAndAssignTasksToPQ(){
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
                    //task already due
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
    
    

    //virtual calendar ---->>> real calendar with name "ScheduledTaskCalendar"
    private func scheduleToRealCalendar(){
        var index = 0
        while(index < virtualCalendar.count) {
            let status = virtualCalendar[index].status
            print("outerloop \(index) status: \(status)")
            if status != "empty" && status != "sleep" && !status.contains("users") {
                let startDate = virtualCalendar[index].startDate
                var endDate = virtualCalendar[index].endDate
                while(virtualCalendar[index].status == status && index < virtualCalendar.count-1){
                    print("innerloop \(index) status: \(status)")
                    endDate = virtualCalendar[index].endDate
                    index += 1
                }
                let interval = VirtualInterval(startDate: startDate, endDate: endDate, status: status)
                print("about to write to calendar")
                writeEventToCalendar(interval: interval)
                print("just wrote to calendar")
            } else {
                index += 1
            }
        }
        
    }

    
    
    //add a task to the virtual calendar (front load)
    private func addTaskToVirtualCalendar(task: Task) -> Bool {
        var duration = task.duration
        for i in 0..<virtualCalendar.count{
            //task.earliestStartDate = Date() //TODO when user pick a earliest start time
            if virtualCalendar[i].startDate >= task.earliestStartDate! && virtualCalendar[i].endDate <= task.dueDate && virtualCalendar[i].status == "empty" && duration > 0{
                virtualCalendar[i].status = task.name
                duration -= 0.5
                if(duration == 0) {
                    return true
                }
            }
            else if virtualCalendar[i].startDate > task.dueDate || task.dueDate < virtualCalendar[i].endDate{
               return false
            }
            
        }
        return false
    }
    
    //load all user's events between current date and latest dueDate to virtural calendar
    private func loadUserEvents(endDate: Date) {
        let currentDate = Date()
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: currentDate, end: endDate, calendars: nil)
        
        // Use the configured NSPredicate to find and return events in the store that match
        //Returns [EKEvent]
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
                        
                        virtualCalendar[i].status = "users " + e.title
                        
                        
                    }
                }
               
            }
        }
    }
    

    private func writeEventToCalendar(interval: VirtualInterval) {
        for cal in self.calendars {
            print(cal.title)
            // 2
            if cal.title == "ScheduledTaskCalendar"{
                let newEvent = EKEvent(eventStore: eventStore)
                newEvent.calendar = cal
                newEvent.title = interval.status
                newEvent.startDate = interval.startDate
                newEvent.endDate = interval.endDate
                print("***In write event to calendar: \(newEvent.title)")

            // Save the calendar using the Event Store instance
            
                do {
                    try eventStore.save(newEvent, span: .thisEvent, commit: true)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
            }
        }
        
       
    }
    
    private func requestAccessToCalendar() {
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
