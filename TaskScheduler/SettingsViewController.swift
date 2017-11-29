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
       // DataManager.loadDataManager()
        if let dataManager = DataManager.sharedInstance {
            focusTimePicker.countDownDuration = TimeInterval(dataManager.focusTime*3600)
            eatingTimePicker.countDownDuration = TimeInterval(dataManager.eatingTime*3600)
            bedTimePicker.date = dataManager.bedTime
            lunchTimePicker.date = dataManager.lunchTime
            dinnerTimePicker.date = dataManager.dinnerTime
            startTimePicker.date = dataManager.startTime
        }
        print("finish loading")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func revertAction(_ sender: Any) {
        
    }
    
    
    @IBAction func saveAction(_ sender: Any) {
        /*DataManager.sharedInstance.bedTime = bedTimePicker.date
        DataManager.sharedInstance.focusTime = Float(focusTimePicker.countDownDuration)
        DataManager.sharedInstance.eatingTime = Float(eatingTimePicker.countDownDuration)
        DataManager.sharedInstance.startTime = startTimePicker.date
        DataManager.sharedInstance.lunchTime = lunchTimePicker.date
        DataManager.sharedInstance.dinnerTime = dinnerTimePicker.date*/
        
        let bedTimeDate = bedTimePicker.date
        let focusTimeFloat = Float(focusTimePicker.countDownDuration)/3600
        let eatingTimeFloat = Float(eatingTimePicker.countDownDuration)/3600
        let startTimeDate = startTimePicker.date
        let lunchTimeDate = lunchTimePicker.date
        let dinnerTimeDate = dinnerTimePicker.date
        
        DataManager.sharedInstance = DataManager.init(startTime: startTimeDate, lunchTime: lunchTimeDate, dinnerTime: dinnerTimeDate, bedTime: bedTimeDate, focusTime: focusTimeFloat, eatingTime: eatingTimeFloat)
        //DataManager.sharedInstance.secureKeyChain()
        DataManager.sharedInstance.saveDataManager()
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
