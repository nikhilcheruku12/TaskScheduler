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
    //Counter variables
    private var freeTime: Double
    private var numTasks: Int
    private var timeRemaining: Double
    private var tasksRemaining: Int
    private var sleepTime: Int
    private var wakeUpTime: Int
    private var lunchTime: Int
    private var dinnerTime: Int
    private var hoursToEat: Int
    private var focusHour: Double
    //Notification variables
    private var notificationCenter: Notification
    
    //Calendar variables
    private var ekCalendar: EKCalendar!
    private let eventStore: EKEventStore
    private var calendars : [EKCalendar]
    private var taskCalendar : EKCalendar
    private var events: [EKEvent]?
    private var virtualCalendar = [VirtualInterval]()
    private var latestDateDue: Date?
    
    //Task & priority queue variables
    private var tasks: [Task]?
    private var pq: PriorityQueue<Task>
    
    var pqTasks = [Task]()
    
    struct VirtualInterval {
        var startDate: Date
        var endDate : Date
        var status: String
    }
    
    init?(tasks: [Task]?){
        //init calendar variables
        self.eventStore = EKEventStore()
        self.taskCalendar = EKCalendar(for: .event, eventStore: eventStore)
        self.calendars = eventStore.calendars(for: EKEntityType.event)
        //init task variables
        self.tasks = tasks
        self.pq = PriorityQueue<Task>(ascending: false)
        //init counter variables
        self.tasksRemaining = (tasks?.count)!
        self.freeTime = 0.0
        self.numTasks = (tasks?.count)!
        self.timeRemaining = 0.0
        //self.tasksRemaining = 0
        self.sleepTime = Singleton.sharedSingleton.sleepTime
        self.wakeUpTime = Singleton.sharedSingleton.wakeUpTime
        self.lunchTime = 12
        self.dinnerTime = 18
        self.hoursToEat = 1
        self.focusHour  = 3.0 // work 4 hours then break
        
        self.lunchTime = DataManager.getHour(date: DataManager.sharedInstance.lunchTime)
        self.dinnerTime = DataManager.getHour(date: DataManager.sharedInstance.dinnerTime)
        self.sleepTime = DataManager.getHour(date: DataManager.sharedInstance.bedTime)
        self.wakeUpTime = DataManager.getHour(date: DataManager.sharedInstance.startTime)
        self.focusHour = Double(DataManager.sharedInstance.focusTime)
        self.hoursToEat = Int(Double(DataManager.sharedInstance.eatingTime))
        
        print("********* lunch time \(self.lunchTime)")
        print("dinner time \(self.dinnerTime)")
        print("sleep time \(self.sleepTime)")
        print("wakup time \(self.wakeUpTime)")
        print("focus hour \(self.focusHour)")
        print("hoursToEat \(self.hoursToEat) ***********")
        //init notification variables
        self.notificationCenter = Notification()
        //create virtual and real calendar
        self.initialVirtualCalAndAssignTasksToPQ()
        self.requestAccessToCalendar()
        self.createTaskCalendar()
        
    }
    
    /*** FUNCTIONS CALLED FROM TABLEVIEWCONTROLLER ***/
    
    /* Called from TableViewController before trying to schedule the
     * user's tasks. Will delete the events previously scheduled in the
     * user's calendar between the current time and the latest due date
     * to avoid conflicts in case the user chooses to edit or delete
     * their tasks or otherwise re-schedule.
     */
    
    public func deleteTasksFromCalendar(){
        var arrayCal : [EKCalendar]?
        for cal in self.calendars {
            if cal.title == "ScheduledTaskCalendar"{
                arrayCal = [EKCalendar]()
                arrayCal?.append(cal)
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
        }
        
    }
    
    
    /* Called when the "test" button is clicked on the home screen.
     * Pops each task from the priority queue and tries to schedule it in the
     * virtual calendar. If any task failes to schedule, returns a failure message
     * to TableViewController. If all tasks succeeded, will schedule
     * on the user's actual calendar.
     */
    public func schedule() -> String{
        if self.latestDateDue != nil{
            loadUserEvents(endDate: self.latestDateDue!)
            var tempHourFoused = 0.0 //number of hours spending consectively
            var currentIndex = 0;//loop once virtual calendar by keeping track where we are
            while pq.count != 0{
                if let t = pq.pop(){
                    let success = addTaskToVirtualCalendar(task: t, timeSpentInChunk: &tempHourFoused , index : &currentIndex )
                    if !success {
                        //Return an error message to TableViewController with the task that could not be scheduled.
                        pqTasks.removeAll()
                        return ("You failed to schedule " + t.name + ". Please try to start the task earlier or reduce its duration and reschedule.")
                    } else {
                        pqTasks.append(t)
                        tasksRemaining -= 1
                    }
                }
            }
        }
        //Schedules the tasks on the real calendar if all were successfully added to the virtual calendar.
        scheduleToRealCalendar()
        return "Scheduling succeeded"
    }
    
    /*
     * Called from schedule(). Reads through the user's calendars and stores their previously
     * scheduled events in the virtual calendar to mark those times as busy.
     */
    private func loadUserEvents(endDate: Date) {
        let currentDate = Date()
        // Use an event store instance to create and properly configure an NSPredicate
        let eventsPredicate = eventStore.predicateForEvents(withStart: currentDate, end: endDate, calendars: nil)
        
        // Use the configured NSPredicate to find and return events in the store that match
        // Returns [EKEvent]
        self.events = eventStore.events(matching: eventsPredicate).sorted(){
            (e1: EKEvent, e2: EKEvent) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
        if self.events != nil{
            print(events!.count)
            // Put user's events in the virtual calendar
            for e in self.events!{
                print(e.title)
                if e.isAllDay{//skip all day event such as holiday, daylight saving etc.
                    continue
                }
                for i in 0..<virtualCalendar.count{
                    if (virtualCalendar[i].startDate <= e.startDate &&
                        e.startDate < virtualCalendar[i].endDate) ||
                        (e.startDate <= virtualCalendar[i].startDate &&
                            virtualCalendar[i].endDate <= e.endDate) ||
                        (virtualCalendar[i].startDate < e.endDate &&
                            e.endDate <= virtualCalendar[i].endDate)
                    {
                        //If the event's start date and end date are both valid
                        virtualCalendar[i].status = "users " + e.title
                        
                    }
                }
            }
        }
    }
    
    /*
     * Called from schedule(). Adds a single task to the virtual calendar. Finds the earliest possible time to slot it in and
     * schedules as much of the task as possible before a) the entire task has been scheduled
     * or b) the user has something else scheduled at the next interval.
     * Returns true if the task was successfully scheduled and false if not.
     */
    private func addTaskToVirtualCalendar(task: Task, timeSpentInChunk: inout Double, index : inout Int) -> Bool {
        var duration = task.duration
        var findIndex = false
        for i in index..<virtualCalendar.count{
            /* (1) The task's earlist possible start time must be before or at the given interval's start date
             * (2) The task's end time must be after or on the given interval's end date
             * (3) The given interval must be empty
             * (4) The task's duration must be greater than 0, i.e. there is part of it left to schedule.
             */
            if virtualCalendar[i].startDate >= task.earliestStartDate! && virtualCalendar[i].endDate <= task.dueDate && virtualCalendar[i].status == "empty" && duration > 0 {
                // "Schedule" the task into the virtual calendar and decrement duration.
                if (timeSpentInChunk >= focusHour){
                    timeSpentInChunk = 0.0
                    virtualCalendar[i].status = "Break Time"
                    continue
                }
                virtualCalendar[i].status = task.name
                duration -= 0.5
                timeSpentInChunk += 0.5
                if(duration == 0) {
                    if(!findIndex) {
                        index = i + 1
                    }
                    // Create a notification to be sent when the task is supposed to be due.
                    notificationCenter.createNotification(date: virtualCalendar[i].endDate, taskName: task.name)
                    return true
                }
            }
            else if virtualCalendar[i].startDate > task.dueDate || task.dueDate < virtualCalendar[i].endDate{
                // Task can not be successfully scheduled at all
                return false
            }else if virtualCalendar[i].status != "empty"{
                timeSpentInChunk = 0.0
            }else if virtualCalendar[i].status == "empty" && virtualCalendar[i].startDate < task.earliestStartDate! && !findIndex{
                    findIndex = true
                    index = i
                    //find the first empty slot that is not scheduled
            }
        }
        
        return false
    }
    
    /* Called from schedule(). Iterates through the virtual calendar and
     * adds all of the user's tasks to their real calendar. Creates a virtualInterval
     * for the total time the user can work on a given task at that time and writes that interval
     * to the calendar using writeEventToCalendar(interval: interval).
     */
    private func scheduleToRealCalendar(){
        var index = 0
        while(index < virtualCalendar.count) {
            //virtualCalendar[index] = the task at that half hour
            let status = virtualCalendar[index].status
            if status == "empty" || status == "BreakTime" {
                freeTime += 0.5
                //print("freetime is : \(freeTime)")
            }
            if status != "empty" && status != "sleep" && !status.contains("users") {
                let startDate = virtualCalendar[index].startDate
                var endDate = virtualCalendar[index].endDate
                //to ensure the interval spans the entire duration of the scheduled task
                while(virtualCalendar[index].status == status && index < virtualCalendar.count){
                    endDate = virtualCalendar[index].endDate
                    index += 1
                    
                    if (index == virtualCalendar.count){
                        //index boundary check
                        break
                    }
                }
                
                let interval = VirtualInterval(startDate: startDate, endDate: endDate, status: status)
                //writes the interval to the real calendar
                writeEventToCalendar(interval: interval)
            } else {
                index += 1
            }
        }
        
    }
    
    /* Called from scheduleToRealCalendar().
     * Given a VirtualInterval, finds the ScheduledTaskCalendar
     * and adds the scheduled task to it.
     */
    private func writeEventToCalendar(interval: VirtualInterval) {
        for cal in self.calendars {
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
    
    /*** INITIALIZATION FUNCTIONS ***/
    
    /*
     *  Creates a new calendar for us to schedule our tasks on, called ScheduledTaskCalendar.
     *  If we have previously created this calendar, the function simply returns.
     */
    private func createTaskCalendar(){
        for cal in calendars{
            if cal.title == "ScheduledTaskCalendar" {
                return
            }
        }
        taskCalendar.title = "ScheduledTaskCalendar"
        // Access list of available sources from the Event Store
        // Filter the available sources and select the "iCloud" source to assign to the new calendar
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
        
        // Save the calendar using the Event Store instance
        do {
            try eventStore.saveCalendar(taskCalendar, commit: true)
            self.calendars = eventStore.calendars(for: .event)
            UserDefaults.standard.set(taskCalendar.calendarIdentifier, forKey: "TaskSchedulerPrimaryCalendar")
            print("Successfully created ScheduledTaskCalendar")
        } catch {
            let alert = UIAlertController(title: "Calendar could not save", message: (error as NSError).localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            print("ScheduledTaskCalendar cannot be created \(error)")
        }
    }
    
    /*
     * Initializes the virtual calendar, an array of VirtualInterval with the number of half hour increments
     * between the current and latest due date.
     * calls Task.assignWeightToTask(task: t) for every task and then adds them to the
     * priority queue.
     */
    private func initialVirtualCalAndAssignTasksToPQ(){
        /* Find latest due date and push all tasks due in future into the priority queue.
         * Truncates the current date to the whole hour.
         */
        self.latestDateDue = Date()
        var currentDate = Date()
        let timeIntervalCurrent = floor(currentDate .timeIntervalSinceReferenceDate / 3600.0) * 3600.0
        currentDate = Date(timeIntervalSinceReferenceDate: timeIntervalCurrent+3600)
        
        if self.tasks != nil{
            for t in self.tasks!{
                if(currentDate < t.dueDate && !t.isComplete()){
                    Task.assignWeightToTask(task: t)
                    pq.push(t)
                    if self.latestDateDue! < t.dueDate{
                        self.latestDateDue = t.dueDate
                    }
                }
            }
        }
        
        // Truncate latest Due Date down to the hour
        let timeIntervalLatest = floor((latestDateDue? .timeIntervalSinceReferenceDate)! / 3600.0) * 3600.0
        self.latestDateDue = Date(timeIntervalSinceReferenceDate: timeIntervalLatest)
        
        let halfHoursBetweenCurrentDateAndLatestDate = Int(self.latestDateDue!.timeIntervalSince(currentDate))/1800
        
        for i in 0..<halfHoursBetweenCurrentDateAndLatestDate{
            let timeBegin = Date(timeInterval: (TimeInterval(i * 1800)), since: currentDate)
            let timeEnd = Date(timeInterval: (TimeInterval(1800)), since: timeBegin)
            // Create virtual interval
            var interval: VirtualInterval
            let currentIntervalBegin = Calendar.current.component(.hour, from: timeBegin)
            let currentIntervalEnd = Calendar.current.component(.hour, from: timeEnd)
            
            // Schedule the user's sleep and eat
            if (((currentIntervalBegin >= sleepTime || currentIntervalBegin < wakeUpTime)
                && (currentIntervalEnd >= sleepTime || currentIntervalEnd <= wakeUpTime) && (sleepTime > wakeUpTime))
                || ((currentIntervalBegin >= sleepTime && currentIntervalBegin < wakeUpTime)
                    && (currentIntervalEnd >= sleepTime && currentIntervalEnd <= wakeUpTime) && (sleepTime < wakeUpTime))
                || ((currentIntervalBegin >= lunchTime && currentIntervalBegin < (lunchTime+hoursToEat))
                    && (currentIntervalEnd >= lunchTime && currentIntervalEnd <= (lunchTime+hoursToEat)))
                || ((currentIntervalBegin >= dinnerTime && currentIntervalBegin<(dinnerTime+hoursToEat)))
                && (currentIntervalEnd >= dinnerTime && currentIntervalEnd<=(dinnerTime+hoursToEat)))
                
            {
                interval = VirtualInterval(startDate: timeBegin, endDate: timeEnd, status: "sleep")
            } else {
                // All other intervals are initialized to empty
                interval = VirtualInterval(startDate: timeBegin, endDate: timeEnd, status: "empty")
            }
            virtualCalendar.append(interval)
        }
    }
    
    /*
     * Pops up a request to get access to the user's calendar.
     */
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
    
    /******HELPER FUNCTIONS********/
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
    
    public func getScheduleMessage() -> String{
        var hours = 0.0
        var days = 0
        var weeks = 0
        var message = ""
        while (freeTime >= 24){
            freeTime -= 24
            days += 1
        }
        hours = freeTime
        if(days >= 7) {
            weeks = days / 7
            days = days % 7
        }
        if(weeks != 0){
            message += "\(weeks)weeks "
        }
        if(days != 0){
            message += "\(days)days "
        }
        message  += "\(hours)hours"
        return message
        
    }
    
    /******GETTER/SETTER FUNCTIONS********/
    
    public func getNumTasks() -> Int {
        return numTasks
    }
    
    public func getTasksRemaining() -> Int {
        return tasksRemaining
    }
    
    /****** FUNCTIONS FOR LATER USE ********/
    
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

