//
//  ScheduledTasksTableViewController.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 11/5/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit

class ScheduledTasksTableViewController: UITableViewController {
    var scheduledTasks = [Task]()
    var classes = [Class]();
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduledTasks = Singleton.sharedSingleton.pqTasks
        print("number of scheduledTasks \(scheduledTasks.count)")
        self.tableView.rowHeight = 90.0;
        navigationItem.rightBarButtonItem = editButtonItem
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let image = UIImage(named: "simpson.png")
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0.0);
        image?.draw(in: self.view.bounds)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        self.view.backgroundColor = UIColor(patternImage: newImage!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func viewWillAppear(_ animated: Bool) {
        scheduledTasks = Singleton.sharedSingleton.pqTasks
        self.tableView.reloadData()
        Singleton.saveSingleton()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scheduledTasks.count;
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduledTasksTableViewCell", for: indexPath) as? ScheduledTasksTableViewCell else{
            fatalError("The dequed cell is not an instance of tableViewCell")
        }
        
        // Configure the cell...
        print("Configure the cell..." )
        let task1 = scheduledTasks[indexPath.row]
        cell.taskNameLabel.text = "\(indexPath.row + 1): " + task1.getName() + " in class " + task1.getClass().getName()
        let percentageFinished = Int(task1.getPercentageFinished() * 100)
        if percentageFinished == 100 {
            cell.taskPercentComplete.text = "Complete"
        }else{
            cell.taskPercentComplete.text = "\(percentageFinished)%"
        }
        cell.taskNameLabel.textColor = uiColorFromHex(rgbValue:colorArray[Int(task1.getClass().getColorNumber())])
        return cell
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    let colorArray = [0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff]
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            scheduledTasks.remove(at: indexPath.row)
            Singleton.sharedSingleton.pqTasks.remove(at: indexPath.row)
            Singleton.saveSingleton()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    private func loadClasses() -> [Class]?  {
        /*previous code exist bug
         ClassManager.sharedInstance.setClasses(classes: (NSKeyedUnarchiver.unarchiveObject(withFile: Class.ArchiveURL.path) as? [Class])!)
         return NSKeyedUnarchiver.unarchiveObject(withFile: Class.ArchiveURL.path) as? [Class]
         */
        if let classes = NSKeyedUnarchiver.unarchiveObject(withFile: Class.ArchiveURL.path) as? [Class]{
            ClassManager.sharedInstance.setClasses(classes: classes )
        }
        return NSKeyedUnarchiver.unarchiveObject(withFile: Class.ArchiveURL.path) as? [Class]
    }
    private func loadSampleClasses() {
        guard let class1 = Class(name: "CS 201", importance: 9, colorNumber: 3, id:Singleton.sharedSingleton.generateNewClassID())
            else {
                fatalError("Unable to instantiate class1")
        }
        guard let class2 = Class(name: "REL 135", importance: 4, colorNumber: 4, id:Singleton.sharedSingleton.generateNewClassID())
            else {
                fatalError("Unable to instantiate class2")
        }
        
        classes += [class1,class2];
    }
    @IBAction func schedule(_ sender: Any) {
        //notificationCenter.createMilkNotification() //testing
        
        if let savedClasses = loadClasses() {
            classes = savedClasses
        }
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
            Singleton.sharedSingleton.pqTasks.removeAll()
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
            //let numTasks = schedulingAlgorithm!.getNumTasks()
            let message = "You have scheduled \(tasksToSchedule) task(s) and still have " +  scheduleMessage + " of free time to enjoy before your last task is due!\n Use that time wisely :)"
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
        scheduledTasks = Singleton.sharedSingleton.pqTasks
        self.tableView.reloadData()
        Singleton.saveSingleton()

    }
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
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "TaskViews", bundle: nil)
        let taskView = storyboard.instantiateViewController(withIdentifier: "TaskViewController") as! TaskViewController
        taskView.class1 = scheduledTasks[indexPath.row].getClass()
        taskView.task1 = scheduledTasks[indexPath.row]
        self.navigationController?.pushViewController(taskView, animated: true)
    }
}

