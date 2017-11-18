//
//  SecondViewController.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 11/17/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let stroyboardName = "TaskViews"
        let controller = "ScheduledTasksTableViewController"
        let storyBoard: UIStoryboard = UIStoryboard(name: stroyboardName, bundle: nil)
        let mainTabBarController: ScheduledTasksTableViewController = storyBoard.instantiateViewController(withIdentifier: controller) as! ScheduledTasksTableViewController
        present(mainTabBarController, animated: true, completion: nil)
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
