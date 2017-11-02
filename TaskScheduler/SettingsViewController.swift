//
//  SettingsViewController.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 10/18/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import UIKit
import os.log

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
 
    @IBOutlet weak var bedtimePicker: UIDatePicker!
    
    @IBOutlet weak var wakeupPicker: UIDatePicker!
    
    @IBOutlet weak var lunchPicker: UIDatePicker!
    
    @IBOutlet weak var dinnerPicker: UIDatePicker!
    
    @IBOutlet weak var hourPicker: UIPickerView!
    
    var hourArray: [String] = []
    var minArray: [String] = ["0", "30"]
    
    @IBOutlet weak var minPicker: UIPickerView!
    
    @IBOutlet weak var focusPicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourPicker.tag = 0
        self.hourPicker.dataSource = self
        self.hourPicker.delegate = self
        for index in 0...100 {
            let temp = "\(index)"
            hourArray.append(contentsOf: [temp])
        }
        
        minPicker.tag = 1
        self.minPicker.dataSource = self
        self.minPicker.delegate = self
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
    }
}


