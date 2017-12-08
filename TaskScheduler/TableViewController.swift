//
//  TableViewController.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/10/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit
import EventKit
import os.log
import UserNotifications
class TableViewController: UITableViewController {
    var classes = [Class]();
    var notificationCenter = Notification()
    let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.leftBarButtonItem = editButtonItem
        //notification
        notificationCenter.setNotification()
        
        //loadSampleClasses()
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted {
                print("access granted")
            } else {
                print("access not granted")
            }
        })
        
        Singleton.sharedSingleton.sleepTime = 23
        Singleton.sharedSingleton.wakeUpTime = 8
        loadSingleton()
        if let savedClasses = loadClasses() {
            classes += savedClasses
        }
            
        else{
            loadSampleClasses()
        }
        
    }
    
    
    
    
    //source from https://useyourloaf.com/blog/openurl-deprecated-in-ios10/
    private func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
    
    //james maya
    @IBAction func testing(_ sender: UIButton) {
        notificationCenter.createMilkNotification() //testing
        var tasks = [Task]()
        for c in classes {
            tasks += c.getTasks()
        }
        var tasksToSchedule = 0
        for t in tasks {
            if (Date() < t.getDueDate() && !t.isComplete()){
                tasksToSchedule += 1
            }
        }
        if(tasksToSchedule < 1){
            Singleton.sharedSingleton.pqTasks.removeAll()
            Singleton.saveSingleton()
            return
        }
        
        let schedulingAlgorithm : SchedulingAlgorithm?
        schedulingAlgorithm = SchedulingAlgorithm(tasks: tasks)!
        
        schedulingAlgorithm?.deleteTasksFromCalendar()
        let scheduleStatus = schedulingAlgorithm?.schedule()
        if scheduleStatus!.contains("failed") {
            print("schedule task not success!!!!!!!!!!")
            let tasksRemaining = schedulingAlgorithm!.getTasksRemaining()
            let message = scheduleStatus! + " You still have \(tasksRemaining) tasks to schedule."
            let alert = UIAlertController(title: "Scheduling Unsuccessful.", message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }else {
            print("Scheduled task SUCCESS!!!!!!!!!!")
            let scheduleMessage = schedulingAlgorithm!.getScheduleMessage()
            let numTasks = schedulingAlgorithm!.getNumTasks()
            let message = "You have scheduled \(numTasks) task(s) and still have " +  scheduleMessage + " of free time to enjoy before your last task is due!\n Use that time wisely :)"
            let alert = UIAlertController(title: scheduleStatus, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go to Calendar", style: .default, handler: { action in
                self.open(scheme: "calshow://")
            }))
            
            //let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            //alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            Singleton.sharedSingleton.pqTasks = (schedulingAlgorithm?.pqTasks)!
            Singleton.saveSingleton()
        }
        schedulingAlgorithm?.printVirtualCalendar()
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return classes.count;
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClassTableViewCell", for: indexPath) as? ClassTableViewCell else{
            fatalError("The dequed cell is not an instance of tableviewcell")
        }
        
        let class1 = classes[indexPath.row]
        cell.nameLabel.text = class1.getName();
        var importance = "";
        if(class1.getImportance() >= 6.66){
            importance = "Very"
        }else if(class1.getImportance() <= 3.33){
            importance = "Low"
        }else {
            importance = "Medium"
        }
        
        cell.importanceLabel.text = "Importance: " +  importance;
        cell.colorView.backgroundColor = uiColorFromHex(rgbValue: colorArray[Int(class1.getColorNumber())])
        
        // Configure the cell...
        
        return cell
    }
    
    //MARK: - ACTIONS
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? ClassViewController, let class1 = sourceViewController.class1 {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                classes[selectedIndexPath.row] = class1
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else{
                let newIndexPath = IndexPath(row: classes.count, section: 0);
                classes.append(class1)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            saveClasses()
            
        }
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            classes.remove(at: indexPath.row)
            saveClasses()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new class.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let classDetailViewController = segue.destination as? ClassViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedclassCell = sender as? ClassTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedclassCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedClass = classes[indexPath.row]
            classDetailViewController.class1 = selectedClass
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
    
    
    private func loadSampleClasses() {
        guard let class1 = Class(name: "CS 201", importance: 9, colorNumber: 3, id:ClassManager.sharedInstance.generateNewClassID())
            else {
                fatalError("Unable to instantiate class1")
        }
        guard let class2 = Class(name: "REL 135", importance: 4, colorNumber: 4, id:ClassManager.sharedInstance.generateNewClassID())
            else {
                fatalError("Unable to instantiate class2")
        }
        
        classes += [class1,class2];
    }
    
    public func saveClasses() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(classes, toFile: Class.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Classes successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save classes...", log: OSLog.default, type: .error)
        }
    }
    
    
    private func loadClasses() -> [Class]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Class.ArchiveURL.path) as? [Class]
    }
    private func loadSingleton(){
        if let singleton = NSKeyedUnarchiver.unarchiveObject(withFile: Singleton.ArchiveURL.path) as? Singleton{
            Singleton.sharedSingleton.dinnerTime = singleton.dinnerTime
            Singleton.sharedSingleton.lunchTime = singleton.lunchTime
            Singleton.sharedSingleton.sleepTime = singleton.sleepTime
            Singleton.sharedSingleton.wakeUpTime = singleton.wakeUpTime
            Singleton.sharedSingleton.focusTime = singleton.focusTime
            Singleton.sharedSingleton.hoursToEat = singleton.hoursToEat
            Singleton.sharedSingleton.pqTasks = singleton.pqTasks
            
        }
        
    }
    
}

