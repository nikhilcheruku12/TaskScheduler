//
//  TableViewController.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/10/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit
import os.log
class TableViewController: UITableViewController {
    var classes = [Class]();

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedClasses = loadClasses() {
            classes += savedClasses
        }
        
        else{
            loadSampleClasses()
        }
        
        
    }

    //james maya
    @IBAction func testing(_ sender: UIButton) {
        var tasks = [Task]()
        for c in classes {
            tasks += c.tasks
        }
        let schedulingAlgorithm : SchedulingAlgorithm?
        
        schedulingAlgorithm = SchedulingAlgorithm(tasks: tasks)!
        schedulingAlgorithm!.initializeVirtualCal()
        

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
        cell.nameLabel.text = class1.name;
        cell.importanceLabel.text = "Importance: " +  class1.importance.description;
        

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
       guard let class1 = Class(name: "CS 201", importance: 9)
        else {
            fatalError("Unable to instantiate class1")
        }
        guard let class2 = Class(name: "REL 135", importance: 4)
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

}
