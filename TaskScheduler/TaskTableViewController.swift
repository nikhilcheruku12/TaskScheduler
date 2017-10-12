//
//  TableViewController.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/10/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit
import os.log
class TaskTableViewController: UITableViewController {
    var tasks = [Task]();
     var class1: Class?
    override func viewDidLoad() {
        super.viewDidLoad()
                // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.leftBarButtonItem = editButtonItem
        if let classtemp = class1{
                tasks = classtemp.tasks 
        }
        
        
        /*else{
            loadSampletasks()
        }*/
        
        
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
        return tasks.count;
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else{
            fatalError("The dequed cell is not an instance of tableviewcell")
        }
        
        let Task1 = tasks[indexPath.row]
        cell.nameLabel.text = Task1.name;
        //cell.importanceLabel.text = "Importance: " +  Task1.importance.description;
        
        
        // Configure the cell...
        
        return cell
    }
    
    //MARK: - ACTIONS
    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
        print("Enters unwindToTaskList");
        if let sourceViewController = sender.source as? TaskViewController, let task1 = sourceViewController.task1 {
           
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                 print("Enters unwindToTaskList2");
                tasks[selectedIndexPath.row] = task1
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else{
                print("Enters unwindToTaskList3");
                let newIndexPath = IndexPath(row: tasks.count, section: 0);
                tasks.append(task1)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            
           // savetasks()
              print("Exits unwindToTaskList");
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
            tasks.remove(at: indexPath.row)
            class1?.tasks.remove(at: indexPath.row)
            //savetasks()
            //saveclasses()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate Task, insert it into the array, and add a new row to the table view
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
        
        if class1 != nil {
            print("class not nil in TaskTableViewController")
        } else{
            print("class is nil in TaskTableViewController")
        }
        super.prepare(for: segue, sender: sender)
        if let destinationViewController = segue.destination as? TaskViewController{
            destinationViewController.class1 = class1;
            print("Class name in TableTaskViewController: = " + (class1?.name)!)
        } else if  let destinationViewController = segue.destination as? UINavigationController {
           let myVC = destinationViewController.viewControllers.first as! TaskViewController
            myVC.class1 = class1
        }else{
            print("TaskViewController was not destinationviewcontroller")
        }
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new Task.", log: OSLog.default, type: .debug)
            
            
        case "ShowDetail":
            guard let TaskDetailViewController = segue.destination as? TaskViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedTaskCell = sender as? TaskTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTaskCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedTask = tasks[indexPath.row]
            TaskDetailViewController.task1 = selectedTask
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
    
    
    /*private func loadSampletasks() {
        guard let Task1 = Task(name: "CS 201", importance: 9)
            else {
                fatalError("Unable to instantiate Task1")
        }
        guard let Task2 = Task(name: "REL 135", importance: 4)
            else {
                fatalError("Unable to instantiate Task2")
        }
        
        tasks += [Task1,Task2];
    }*/
    
   /*private func savetasks() {
        print("Enters savetasks")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(tasks, toFile: Task.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("tasks successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save tasks...", log: OSLog.default, type: .error)
        }
        print("Exits savetasks")
    }
    
    private func loadtasks() -> [Task]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Task.ArchiveURL.path) as? [Task]
    }*/
    
}
