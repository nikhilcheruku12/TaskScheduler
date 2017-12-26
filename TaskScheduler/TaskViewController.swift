//
//  TaskViewController.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/17/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit
import os.log
class TaskViewController: UIViewController,UITextFieldDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var task1: Task?
    
    var class1: Class?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var percentageSlider: UISlider!
    
    @IBOutlet weak var percentageFinishedSlider: UISlider!
    // @IBOutlet weak var hoursTextField: UITextField!
    
   // @IBOutlet weak var minutesTextField: UITextField!
    
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    @IBOutlet weak var earliestStartTimePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var hourPicker: UIPickerView!
    @IBOutlet weak var minutePicker: UIPickerView!
    
    @IBOutlet weak var percentageGradeLabel: UILabel!
    
    @IBOutlet weak var percentageFinishedLabel: UILabel!
    
    var hourArray: [String] = []
    var minArray : [String] = ["0","30"]
    
    
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
        
        hourPicker.tag = 0
        minutePicker.tag = 1
        self.hourPicker.dataSource = self
        self.hourPicker.delegate = self
        
        self.minutePicker.dataSource = self
        self.minutePicker.delegate = self 
        
        
        
        
        for index in 0...100 {
            let temp = "\(index)"
            hourArray.append(contentsOf: [temp])
        }
        
        if let task1 = task1 {
            print("task is not nil")
            navigationItem.title = task1.getName()
            nameTextField.text = task1.getName()
            percentageSlider.value = task1.getPercentage()
            percentageFinishedSlider.value = task1.getPercentageFinished()
           // hoursTextField.text =  String(Int(floor(task1.duration)))
            //minutesTextField.text =  String(Int(60 * (task1.duration - Float(Int(floor(task1.duration))))))
            hourPicker.selectRow(Int(floor(task1.getDuration())), inComponent: 0, animated: true)
            minutePicker.selectRow(Int(2 * (task1.getDuration() - Float(Int(floor(task1.getDuration())))))
                , inComponent: 0, animated: true)
            dueDatePicker.date = task1.getDueDate()
            earliestStartTimePicker.date = task1.getEarliestStartDate()
        }
        //display slider value on label
        var percentageGrade = Int(percentageSlider.value*100)%100
        if(percentageSlider.value == 1 ) {
            percentageGrade = 100;
        }
        
        percentageGradeLabel.text = "\(percentageGrade)%"
        var percentageFinished = Int(percentageFinishedSlider.value*100)%100
        if(percentageFinishedSlider.value == 1 ) {
            percentageFinished = 100;
        }
        percentageFinishedLabel.text = "\(percentageFinished)%"
        
        
        
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
        
        if hourPicker.selectedRow(inComponent: 0) == 0 &&
            minutePicker.selectedRow(inComponent: 0) == 0{
            
            let alertController = UIAlertController(title: "Invalid Input", message: "Duration cannot be 0 hrs and 0 mins", preferredStyle: .alert)
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
            print("ffbrekfbrejkgbekrjgbejktgbtjkgbekjgbekrjgek")
            task1.setName(name: nameTextField.text!) ;
            task1.setPercentage(percentage: percentageSlider.value);
            task1.setPercentageFinished(percentageFinished: percentageFinishedSlider.value) ;
            //let hours = Float(Int(hoursTextField.text!)!);
            let hours = Float(hourPicker.selectedRow(inComponent: 0))
            //let minutes = Float(Int(minutesTextField.text!)!)/60.0;
            let minutes = Float (minutePicker.selectedRow(inComponent: 0) * 30)/60.0
            task1.setDuration(duration: hours + minutes)  ;
            task1.setDueDate(date: dueDatePicker.date);
            var earliestStartDate = earliestStartTimePicker.date;
            let timeIntervalEarliest = floor(earliestStartDate .timeIntervalSinceReferenceDate / 60) * 60 //truncate seconds
            earliestStartDate = Date(timeIntervalSinceReferenceDate: timeIntervalEarliest)
            task1.setEarliestStartDate(earliestStartDate: earliestStartDate)
            
            self.navigationController?.popViewController(animated: true)//if task exist, go back to previous view
            return false 
            
        }
            
        else{
            if class1 != nil {
                print("class not nil in TaskViewController")
            } else{
                print("class is nil in TaskViewController")
            }
            let name = nameTextField.text;
            let percentage = percentageSlider.value;
            let percentageFinished = percentageFinishedSlider.value;
            let hours = Float(hourPicker.selectedRow(inComponent: 0))
            let minutes = Float (minutePicker.selectedRow(inComponent: 0) * 30)/60.0
            print(minutes)
            let duration = hours + minutes;
            let dueDate = dueDatePicker.date;
            var earliestStartDate = earliestStartTimePicker.date;
            let timeIntervalEarliest = floor(earliestStartDate .timeIntervalSinceReferenceDate / 60) * 60 //truncate seconds
            earliestStartDate = Date(timeIntervalSinceReferenceDate: timeIntervalEarliest)
            task1 = Task(name: name!, percentage: percentage,  class1:class1!, duration:duration, dueDate:dueDate, earliestStartDate:earliestStartDate, percentageFinished:percentageFinished, id:Singleton.sharedSingleton.generateNewTaskID());
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
    
    /*func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
        print("begin")
        
    }*/
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        
        updateSaveButtonState()
        navigationItem.title = nameTextField.text
        print("end")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !(textField.text?.isEmpty)!{
        saveButton.isEnabled = true
        
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 0){
            return hourArray.count
        }
        return minArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            let titleRow = hourArray[row]
            return titleRow
        } else if pickerView.tag == 1 {
            let titleRow = minArray[row]
            return titleRow
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
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
    
    @IBAction func changePercentageOfGrade(_ sender: UISlider) {
        var percentage = Int(percentageSlider.value*100)%100
        if(percentageSlider.value == 1 ) {
            percentage = 100;
        }
        percentageGradeLabel.text = "\(percentage)%"
    }
    
    @IBAction func changePercentageFinished(_ sender: UISlider) {
        var percentage = Int(percentageFinishedSlider.value*100)%100
        if(percentageFinishedSlider.value == 1 ) {
            percentage = 100;
        }
        percentageFinishedLabel.text = "\(percentage)%"
    }
}
