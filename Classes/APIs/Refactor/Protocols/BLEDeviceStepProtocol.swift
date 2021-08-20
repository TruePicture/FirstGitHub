//
//  BLEDeviceStepProtocol.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2020/4/1.
//  Copyright © 2020 ss. All rights reserved.
//

import Foundation

public protocol BLEDeviceStepProtocol {
//    func getUserInfo(callback:((Array<StepTester>?, BLEError?)->Void)?, toDeviceName deviceName:String?) -> BLETask?
//
//    func setUserInfo(info:StepTester,callback:BoolCallback?,toDeviceName deviceName:String?) -> BLETask?
//
//    func getGSensorInfo(callback:((Array<Gsensor>?, BLEError?)->Void)?,toDeviceName deviceName:String?) -> BLETask?
    
    func startUploadData(callback:BoolCallback?,toDeviceName deviceName:String?) -> BLETask?
    
    func stopUploadData(callback:BoolCallback?,toDeviceName deviceName:String?) -> BLETask?
    
}

public extension BLEDeviceStepProtocol {
    
//    func getUserInfo(callback:((Array<StepTester>?, BLEError?)->Void)?, toDeviceName deviceName:String?) -> BLETask?{
//
//        let data = Data([0x7f,0x03,0x70,0x01,0x00,0x00,0x9f])
//        return BLECenter.shared.send(data: data, dataArrayCallback: { (dataArray, error) in
//
//            if callback != nil {
//                if error == nil && dataArray != nil && dataArray!.count > 0 {
//                    let data = dataArray![0];
//                    let subdata = data[1...data.count - 1]
//                    let versionStr = String(bytes: subdata, encoding: String.Encoding.utf8)
//                    callback!(nil, error)
//                }
//                else {
//                    callback!(nil, error)
//                }
//            }
//
//        }, toDeviceName: deviceName)
//    }
//
//    func setUserInfo(info:StepTester,callback:BoolCallback?,toDeviceName deviceName:String?) -> BLETask?{
//
//        let data = Data([0x7f,0x03,0x71,0x05,0x00,0x00,0x00,0x9f])
//        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
//
//    }
//
//    func getGSensorInfo(callback:((Array<Gsensor>?, BLEError?)->Void)?,toDeviceName deviceName:String?) -> BLETask?{
//
//        let data = Data([0x7f,0x04,0x70,0x01,0x00,0x00,0x9f])
//        return BLECenter.shared.send(data: data, dataArrayCallback: { (dataArray, error) in
//
//            if callback != nil {
//                if error == nil && dataArray != nil && dataArray!.count > 0 {
//                    let data = dataArray![0];
//                    let subdata = data[1...data.count - 1]
//                    let versionStr = String(bytes: subdata, encoding: String.Encoding.utf8)
//                    callback!(nil, error)
//                }
//                else {
//                    callback!(nil, error)
//                }
//            }
//
//        }, toDeviceName: deviceName)
//    }
    
    func startUploadData(callback:BoolCallback?,toDeviceName deviceName:String?) -> BLETask?{
        
        let data = Data([0x7f,0x02,0x71,0x02,0x00,0x01,0x0B,0x9f])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
    
    func stopUploadData(callback:BoolCallback?,toDeviceName deviceName:String?) -> BLETask?{
        
        let data = Data([0x7f,0x02,0x71,0x02,0x00,0x01,0x00,0x9f])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
}
