//
//  OtaManager.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/10.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

// BLEKey.task: OtaTask
public let kOtaManagerAddTaskNotification = Notification.Name("kOtaManagerAddTaskNotification")
public let kOtaManagerRemoveTaskNotification = Notification.Name("kOtaManagerRemoveTaskNotification")
public let kOtaManagerRemoveAllTasksNotification = Notification.Name("kOtaManagerRemoveAllTasksNotification")

public class OtaManager {

    public static let shared = OtaManager()
    
    public var taskList = [OtaTask]()
    
    private init () {}
    
    public func startOta(device: BLEDevice, otaBleName: String, otaDatas: [OtaDataModel], readyCallback: EmptyBlock?, progressCallback: FloatCallback?, finishCallback: BoolCallback?) -> OtaTask?{
        
        if device.isOTAing {
            DispatchQueue.main.async {
                finishCallback?(false, BLEError.taskError(reason: .repeatTask))
            }
            return nil
        }
        
        let task = OtaTask(device: device, otaBleName: otaBleName, otaDatas: otaDatas, readyCallback: readyCallback, progressCallback: progressCallback, finishCallback: finishCallback)
        task.start()
        
        taskList = taskList.filter { (t) -> Bool in
            return (t.device.name != task.device.name && t.otaBleName != otaBleName)
        }
        
        taskList.append(task)
        
        
        NotificationCenter.default.post(name: kOtaManagerAddTaskNotification, object: nil, userInfo: [BLEKey.task: task])
        
        return task
    }
    
    
    public func startNordicOta(device: BLEDevice, otaBleName: String, otaDatas: [OtaDataModel], readyCallback: EmptyBlock?, progressCallback: FloatCallback?, finishCallback: BoolCallback?) -> OtaTask?{
        
        if device.isOTAing {
            return nil
        }
        
        let task = OtaNordicTask(device: device, otaBleName: otaBleName, otaDatas: otaDatas, readyCallback: readyCallback, progressCallback: progressCallback, finishCallback: finishCallback)
        task.start()
        taskList.append(task)
        
        
        NotificationCenter.default.post(name: kOtaManagerAddTaskNotification, object: nil, userInfo: [BLEKey.task: task])
        
        return task
    }
    
    public func startTlsrOta(device: BLEDevice, otaBleName: String, otaDatas: [OtaDataModel], readyCallback: EmptyBlock?, progressCallback: FloatCallback?, finishCallback: BoolCallback?) -> OtaTask? {
        if device.isOTAing {
            return nil
        }
        let task = OtaTlsrTask(device: device, otaBleName: otaBleName, otaDatas: otaDatas, readyCallback: readyCallback, progressCallback: progressCallback, finishCallback: finishCallback)
        task.start()
        taskList.append(task)
        
        NotificationCenter.default.post(name: kOtaManagerAddTaskNotification, object: nil, userInfo: [BLEKey.task: task])
        
        return task
    }
    
    
    
    public func removeTask(_ task: OtaTask) {
        taskList.remove(task)
        
        NotificationCenter.default.post(name: kOtaManagerRemoveTaskNotification, object: nil, userInfo: [BLEKey.task: task])
    }
    
    public func cancelTask(_ task: OtaTask) {
        if task.state == .otaing || task.state == .plain {
            task.cancel()
        }
        removeTask(task)
    }
    
    public func cancelAllTask() {
        for task in taskList {
            task.cancel()
        }
        taskList.removeAll()
        NotificationCenter.default.post(name: kOtaManagerRemoveAllTasksNotification, object: nil, userInfo: nil)
    }
    
    
}
