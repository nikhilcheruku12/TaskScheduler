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
    
    @IBOutlet weak var lunchHoursPicker: UIPickerView!
    
    @IBOutlet weak var lunchMinsPicker: UIPickerView!
    
    @IBOutlet weak var focusTimePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

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
