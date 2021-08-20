//
//  BLEDevicePointerCtrlProtocol.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2020/3/9.
//  Copyright © 2020 ss. All rights reserved.
//

import Foundation

public enum LYBCClockPointer:UInt8, Codable {
    case pointerHour = 0
    case pointerMin
    case pointerSecond
}

public enum LYBCDirection:UInt8, Codable {
    case antiClockwise = 0
    case clockwise
    case expand
}

public enum LYBCClockEvent:UInt8, Codable {
    case stop = 0
    case move
    case unLock
    case lock
    case unLockAndSetParams
    case quitCalibration
}

public protocol BLEDevicePointerCtrlProtocol {
    func sendClockEvent(pointer:LYBCClockPointer, direction:LYBCDirection, event:LYBCClockEvent, callback:BoolCallback?, toDeviceName deviceName:String) -> BLETask?
    
    func pointerRotation(pointer:LYBCClockPointer, direction:LYBCDirection, angle:UInt16, callback:BoolCallback?, toDeviceName deviceName:String) -> BLETask?
        
}

public extension BLEDevicePointerCtrlProtocol {
    
    func sendClockEvent(pointer:LYBCClockPointer, direction:LYBCDirection, event:LYBCClockEvent, callback:BoolCallback?, toDeviceName deviceName:String) -> BLETask? {
        
        let data = Data([0x6F,0xB8,0x71,0x03,0x00,pointer.rawValue,direction.rawValue,event.rawValue,0x8F])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
    
    func pointerRotation(pointer:LYBCClockPointer, direction:LYBCDirection, angle:UInt16, callback:BoolCallback?, toDeviceName deviceName:String) -> BLETask? {
        
        let degreeData = angle.data(byteCount: 2)
        
        let data = Data([0x6F,0xB6,0x71,0x04,0x00,pointer.rawValue,direction.rawValue,degreeData[0],degreeData[1],0x8F])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
}
