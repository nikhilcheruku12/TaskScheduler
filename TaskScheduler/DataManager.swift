//
//  DataManager.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 11/7/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import Foundation
import os.log

class DataManager: NSObject, NSCoding {
    struct PropertyKey {
        static let lunchTimeKey = "lunchTimeKey"
        static let dinnerTimeKey = "dinnerTimeKey"
        static let focusTimeKey = "focusTimeKey"
        static let eatingTimeKey = "eatingTimeKey"
        static let bedTimeKey = "bedTimeKey"
        static let startTimeKey = "startTimeKey"
    }
   
    static var sharedInstance: DataManager!
    
    static let keychainItemIdentifier = "edu.usc.TaskScheduler"
    static let dataManagerKey = "dataManagerKey"
    static let lunchTimeKey = "lunchTimeKey"
    static let dinnerTimeKey = "dinnerTimeKey"
    static let focusTimeKey = "focusTimeKey"
    static let eatingTimeKey = "eatingTimeKey"
    static let bedTimeKey = "bedTimeKey"
    static let startTimeKey = "startTimeKey"
    
    var lunchTime: Date!
    var dinnerTime: Date!
    var focusTime: Float
    var eatingTime: Float
    var bedTime : Date!
    var startTime: Date!
    
//    init() {
//        let keychainItem : KeychainItemWrapper = KeychainItemWrapper(identifier: DataManager.keychainItemIdentifier, accessGroup: nil)
//        focusTime = 0
//        eatingTime = 0
//        lunchTime = Date()
//        dinnerTime = Date()
//        startTime = Date()
//        bedTime = Date()
//       
//            let superSecretValue = keychainItem[DataManager.dataManagerKey] as? String?
//        if(superSecretValue! != nil){
//            print("hey this works maybe")
//            let array = self.convertJsonStringToDictionary(superSecretValue!!)
//            for item in array!{
//                self.createDataMangerFromDict(dict: item)
//            }
//        }
//        
//            
//        
//      
//    }
    
    init?(startTime: Date, lunchTime: Date, dinnerTime: Date, bedTime: Date, focusTime: Float, eatingTime: Float) {
        self.startTime = startTime
        self.lunchTime = lunchTime
        self.dinnerTime = dinnerTime
        self.bedTime = bedTime
        self.focusTime = focusTime
        self.eatingTime = eatingTime
    }

    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lunchTime, forKey: PropertyKey.lunchTimeKey)
        aCoder.encode(dinnerTime, forKey: PropertyKey.dinnerTimeKey)
        aCoder.encode(eatingTime, forKey: PropertyKey.eatingTimeKey)
        aCoder.encode(focusTime, forKey: PropertyKey.focusTimeKey)
        aCoder.encode(bedTime, forKey: PropertyKey.bedTimeKey)
        aCoder.encode(startTime, forKey: PropertyKey.startTimeKey)

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let bedTimeDate = aDecoder.decodeObject(forKey: PropertyKey.bedTimeKey) as? Date else {
            os_log("Unable to decode the name for a class object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let startTimeDate = aDecoder.decodeObject(forKey: PropertyKey.startTimeKey) as? Date else {
            os_log("Unable to decode the name for a class object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let lunchTimeDate = aDecoder.decodeObject(forKey: PropertyKey.lunchTimeKey) as? Date else {
            os_log("Unable to decode the name for a class object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let dinnerTimeDate = aDecoder.decodeObject(forKey: PropertyKey.dinnerTimeKey) as? Date else {
            os_log("Unable to decode the name for a class object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let focusTimeFloat = aDecoder.decodeFloat(forKey: PropertyKey.focusTimeKey)
        
        let eatingTimeFloat = aDecoder.decodeFloat(forKey: PropertyKey.eatingTimeKey)
        
        self.init(startTime: startTimeDate, lunchTime: lunchTimeDate, dinnerTime: dinnerTimeDate, bedTime: bedTimeDate, focusTime: focusTimeFloat, eatingTime: eatingTimeFloat)
        
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("datamanager")
    
    
    public func saveDataManager() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(DataManager.sharedInstance, toFile: DataManager.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Classes successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save classes...", log: OSLog.default, type: .error)
        }
    }
    
    
    public static func loadDataManager() -> ()  {
       let dataManager = (NSKeyedUnarchiver.unarchiveObject(withFile: DataManager.ArchiveURL.path) as? DataManager)
        if let temp = dataManager{
            DataManager.sharedInstance = temp
        }
    }

    
 //   func toDict () -> Dictionary<String,AnyObject> {
//        let dict: [String: AnyObject] = [DataManager.lunchTimeKey: lunchTime as AnyObject,
//                                         DataManager.dinnerTimeKey: dinnerTime as AnyObject,
//                                         DataManager.focusTimeKey: focusTime as AnyObject,
//                                         DataManager.eatingTimeKey: eatingTime as AnyObject,
//                                         DataManager.bedTimeKey: bedTime as AnyObject,
//                                         DataManager.startTimeKey: startTime as AnyObject]
//        return dict as Dictionary<String, AnyObject>    }
//    
//    func toString() -> NSString? {
//        return convertDataToString(convertDictionaryToJsonData(toDict())!)
//    }
//    
//    func convertDictionaryToJsonData(_ inputDict : Dictionary<String, AnyObject>) -> Data?{
//        do{
//            return try JSONSerialization.data(withJSONObject: inputDict, options:JSONSerialization.WritingOptions.prettyPrinted)
//        }catch let error as NSError{
//            print(error)
//        }
//        return nil
//    }
//    
//    func convertDataToString(_ inputData : Data) -> NSString?{
//        let returnString = String(data: inputData, encoding: String.Encoding.utf8)
//        return returnString as NSString?
//    }
//
//    func convertJsonStringToDictionary(_ text: String) -> Array<Dictionary<String, AnyObject>>? {if let data = text.data(using: String.Encoding.utf8) {
//        do {
//            return try JSONSerialization.jsonObject(with: data, options: []) as? Array<Dictionary<String, AnyObject>>
//        } catch let error as NSError {
//            print(error)
//        }
//        }
//        return nil
//    }
//
//    func secureKeyChain () -> (){
//        let keychainItemWrapper = KeychainItemWrapper(identifier: DataManager.keychainItemIdentifier, accessGroup:nil)
//        keychainItemWrapper[DataManager.dataManagerKey] = toString() as AnyObject?
//    }
//    
//    func getKeyChain()->(){
//        let keychainItemWrapper = KeychainItemWrapper(identifier: DataManager.keychainItemIdentifier, accessGroup: nil)
//        let superSecretValue = keychainItemWrapper[DataManager.dataManagerKey] as? String?
//        print("The super secret value is: \(String(describing: superSecretValue))");
//        let array = convertJsonStringToDictionary(superSecretValue!!)
//        for item in array!{
//            createDataMangerFromDict(dict: item)
//        }
//        
//    }
//    
//    func createDataMangerFromDict(dict: Dictionary<String, AnyObject>)->(){
//        lunchTime = dict[DataManager.lunchTimeKey] as! Date
//        dinnerTime = dict[DataManager.dinnerTimeKey] as! Date
//        focusTime = dict[DataManager.focusTimeKey] as! Float
//        eatingTime = dict[DataManager.eatingTimeKey] as! Float
//        bedTime = dict[DataManager.bedTimeKey] as! Date
//        startTime = dict[DataManager.startTimeKey] as! Date
//    }

}
