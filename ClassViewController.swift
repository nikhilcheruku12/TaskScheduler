//
//  ClassViewController.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/7/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit
import os.log

class ClassViewController: UIViewController,UITextFieldDelegate, UINavigationControllerDelegate {

    var class1: Class?
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var importanceSlider: UISlider!
    
    @IBOutlet weak var viewTasksButton: UIButton!

    @IBOutlet weak var importanceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        
        if let class1 = class1 {
            navigationItem.title = class1.name
            nameTextField.text = class1.name
            importanceSlider.value = class1.importance
            viewTasksButton.isHidden = false;
            
            if(class1.importance >= 6.66){
                importanceLabel.text = "Very"
            }else if(class1.importance <= 3.33){
                importanceLabel.text = "Low"
            }else {
                importanceLabel.text = "Medium"
            }
        }
        
        else{
            viewTasksButton.isHidden = true;
        }

        
        
        //updateSaveButtonState()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender);
        print("segue is happening in ClassViewController")
        
        if let button = sender as? UIBarButtonItem , button == cancelButton{
            os_log("The save button was not pressed in ClassViewController, cancelling1", log: OSLog.default, type: .debug)
            return
        }
        if let class1 = class1{
            // class1 = Class(name:nameTextField.text!, importance:importanceSlider.value, tasks: tasksArray);
            class1.name = nameTextField.text!
            class1.importance = importanceSlider.value;
        } else{
            class1 = Class(name:nameTextField.text!, importance:importanceSlider.value)
        }

        if class1 != nil {
            print("class not nil in classViewController")
        } else{
            print("class is nil in classViewController")
        }
        
        if let destinationViewController = segue.destination as? TaskTableViewController{
            destinationViewController.class1 = class1;
            print("Class name in TableTaskViewController: = " + (class1?.name)!)
        }else if  let destinationViewController = segue.destination as? UINavigationController {
            let myVC = destinationViewController.viewControllers.first as! TaskTableViewController
            myVC.class1 = class1
        } else{
            print("TaskViewController was not destinationviewcontroller")
        }
        
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        //saveButton.isEnabled = false
       print("begin")
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        
        //updateSaveButtonState()
        navigationItem.title = nameTextField.text
        print("end")
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
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

    @IBAction func changeClassImportance(_ sender: UISlider) {
    
        if(importanceSlider.value >= 6.66){
            importanceLabel.text = "Very"
        }else if(importanceSlider.value <= 3.33){
            importanceLabel.text = "Low"
        }else {
            importanceLabel.text = "Medium"
        }
    }

}
