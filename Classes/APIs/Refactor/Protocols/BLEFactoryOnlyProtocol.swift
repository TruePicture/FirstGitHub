//
//  BLEFactoryOnlyProtocol.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2020/3/3.
//  Copyright © 2020 ss. All rights reserved.
//

import Foundation
public protocol BLEFactoryOnlyProtocol {
    // protocol definition goes here
//    var wheel: Int {get set}
    func checkGesensor(callback:DataArrayCallback?, toDeviceName deviceName:String?) -> BLETask?
    
    func startMotor(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask?

    func stopMotor(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask?
    
    func checkFlash(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask?
    
    func checkHeartRate(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask?
    
    func checkBLEName(callback:StringCallback?, toDeviceName deviceName:String?) -> BLETask?
    
    func checkBuzzer(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask?
}

public extension BLEFactoryOnlyProtocol {

    func checkGesensor(callback:DataArrayCallback?, toDeviceName deviceName:String?) -> BLETask? {
        let data = Data([0x6f, 0xfc, 0x70, 0x01, 0x00, 0x00, 0x8f])
        return BLECenter.shared.send(data: data, dataArrayCallback: callback, toDeviceName: deviceName)
    }

    func startMotor(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask? {
        let data = Data([0x6F, 0xFA, 0x71, 0x01, 0x00, 0x01, 0x8F])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
    
    func stopMotor(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask? {
        let data = Data([0x6F, 0xFA, 0x71, 0x01, 0x00, 0x00, 0x8F])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }

    func checkFlash(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask? {
        let data = Data([0x6F, 0xF7, 0x70, 0x01, 0x00, 0x00, 0x8F])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }

    func checkHeartRate(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask? {
        let data = Data([0x6F, 0xFB, 0x70, 0x01, 0x00, 0x00, 0x8F])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }

    func checkBLEName(callback:StringCallback?, toDeviceName deviceName:String?) -> BLETask? {
        let data = Data([0x6f, 0xf9, 0x70, 0x01, 0x00, 0x00, 0x8f])
        return BLECenter.shared.send(data: data, stringCallback: callback, toDeviceName: deviceName)
    }
    
    func checkBuzzer(callback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask? {
        let data = Data([0x6f, 0xf9, 0x70, 0x01, 0x00, 0x00, 0x8f])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
}
