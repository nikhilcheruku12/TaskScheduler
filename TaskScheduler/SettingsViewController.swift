//
//  SettingsViewController.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 11/6/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var bedTimePicker: UIDatePicker!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    @IBOutlet weak var lunchTimePicker: UIDatePicker!
    
    @IBOutlet weak var dinnerTimePicker: UIDatePicker!
    
    @IBOutlet weak var focusTimePicker: UIDatePicker!
    @IBOutlet weak var eatingTimePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var revertButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("start load")
        focusTimePicker.countDownDuration = TimeInterval(DataManager.sharedInstance.focusTime)
        eatingTimePicker.countDownDuration = TimeInterval(DataManager.sharedInstance.eatingTime)
        bedTimePicker.date = DataManager.sharedInstance.bedTime
        lunchTimePicker.date = DataManager.sharedInstance.lunchTime
        dinnerTimePicker.date = DataManager.sharedInstance.dinnerTime
        startTimePicker.date = DataManager.sharedInstance.startTime
        print("finish loading")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func revertAction(_ sender: Any) {
        
    }
    
    
    @IBAction func saveAction(_ sender: Any) {
        DataManager.sharedInstance.bedTime = bedTimePicker.date
        DataManager.sharedInstance.focusTime = Float(focusTimePicker.countDownDuration)
        DataManager.sharedInstance.eatingTime = Float(eatingTimePicker.countDownDuration)
        DataManager.sharedInstance.startTime = startTimePicker.date
        DataManager.sharedInstance.lunchTime = lunchTimePicker.date
        DataManager.sharedInstance.dinnerTime = dinnerTimePicker.date
        
        //DataManager.sharedInstance.secureKeyChain()
        
        print(DataManager.sharedInstance.bedTime)
        print(DataManager.sharedInstance.startTime)
        print(DataManager.sharedInstance.lunchTime)
        print(DataManager.sharedInstance.dinnerTime)
        print(DataManager.sharedInstance.focusTime)
        print(DataManager.sharedInstance.eatingTime)
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
