//
//  TaskViewController.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/17/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit
import os.log
class TaskViewController: UIViewController,UITextFieldDelegate, UINavigationControllerDelegate {
    
    var task1: Task?
    
    var class1: Class?
    
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var percentageSlider: UISlider!
    
    @IBOutlet weak var hoursTextField: UITextField!
    
    @IBOutlet weak var minutesTextField: UITextField!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    @IBOutlet weak var earliestStartTimePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
      
        // components.year = -18
        let gregorian: NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let currentDate: NSDate = NSDate()
        let components: NSDateComponents = NSDateComponents()
        let minDate: NSDate = gregorian.date(byAdding: components as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))! as NSDate
        
        /*components.year = -150
         let maxDate: NSDate = gregorian.dateByAddingComponents(components as DateComponents, toDate: currentDate, options: NSCalendar.Options(rawValue: 0))!*/
        
        self.earliestStartTimePicker.minimumDate = minDate as Date
        //self.datePicker.maximumDate = maxDate
        
        self.dueDatePicker.minimumDate = earliestStartTimePicker.date
        
        if let task1 = task1 {
            navigationItem.title = task1.name
            nameTextField.text = task1.name
            percentageSlider.value = task1.percentage
            hoursTextField.text =  String(Int(floor(task1.duration)))
            minutesTextField.text =  String(Int(60 * (task1.duration - Float(Int(floor(task1.duration))))))
            dueDatePicker.date = task1.dueDate
            earliestStartTimePicker.date = task1.earliestStartDate!
        }
            
        
        
        
        updateSaveButtonState()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if dueDatePicker.date<=earliestStartTimePicker.date {
            
            let alertController = UIAlertController(title: "Invalid Input", message: "Due Date should be greater then earliest start date", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close Alert", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            return false
        }
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return false
        }
        
        if let task1 = task1{
            task1.name = nameTextField.text!;
            task1.percentage = percentageSlider.value;
            let hours = Float(Int(hoursTextField.text!)!);
            let minutes = Float(Int(minutesTextField.text!)!)/60.0;
            task1.duration = hours + minutes;
            task1.dueDate = dueDatePicker.date;
            var earliestStartDate = earliestStartTimePicker.date;
            let timeIntervalEarliest = floor(earliestStartDate .timeIntervalSinceReferenceDate / 60) * 60 //truncate seconds
            earliestStartDate = Date(timeIntervalSinceReferenceDate: timeIntervalEarliest)
            task1.earliestStartDate = earliestStartDate
        }
            
        else{
            let name = nameTextField.text;
            let percentage = percentageSlider.value;
            let hours = Float(Int(hoursTextField.text!)!);
            let minutes = Float(Int(minutesTextField.text!)!)/60.0;
            let duration = hours + minutes;
            let dueDate = dueDatePicker.date;
            var earliestStartDate = earliestStartTimePicker.date;
            let timeIntervalEarliest = floor(earliestStartDate .timeIntervalSinceReferenceDate / 60) * 60 //truncate seconds
            earliestStartDate = Date(timeIntervalSinceReferenceDate: timeIntervalEarliest)
            task1 = Task(name: name!, percentage: percentage,  class1:class1!, duration:duration, dueDate:dueDate, earliestStartDate:earliestStartDate);
            if let classtemp = class1 {
                classtemp.addTask(task: task1!)
                os_log("task is being saved", log: OSLog.default, type: .debug)
                
            } else{
                os_log("task is not being saved", log: OSLog.default, type: .debug)
            }
        }
        
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
        print("begin")
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        
        updateSaveButtonState()
        navigationItem.title = nameTextField.text
        print("end")
    }
    
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddClassMode = presentingViewController is UINavigationController
        
        if isPresentingInAddClassMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    

}
