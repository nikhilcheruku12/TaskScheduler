//
//  ScheduledTasksNavigationController.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 12/8/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit

class ScheduledTasksNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let stroyboardName = "TaskViews"
        let controller = "ScheduledTasksTableViewController"
        let storyBoard: UIStoryboard = UIStoryboard(name: stroyboardName, bundle: nil)
        let scheduledTaskVC: ScheduledTasksTableViewController = storyBoard.instantiateViewController(withIdentifier: controller) as! ScheduledTasksTableViewController
        pushViewController(scheduledTaskVC, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
