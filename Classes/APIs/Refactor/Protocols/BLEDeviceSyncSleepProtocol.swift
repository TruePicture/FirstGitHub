//
//  BLEDeviceSyncSleepProtocol.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2020/4/1.
//  Copyright © 2020 ss. All rights reserved.
//

import Foundation
public protocol BLEDeviceSyncSleepProtocol {
    func getSleepDetail(num: UInt16, callback:((Array<Sleep>?, BLEError?)->Void)?, toDeviceName deviceName:String?) -> BLETask?
}

public extension BLEDeviceSyncSleepProtocol {
     func getSleepDetail(num: UInt16, callback:((Array<Sleep>?, BLEError?)->Void)?, toDeviceName deviceName:String? = nil)->BLETask? {
           if num == 0 {
               callback?(nil, BLEError.taskError(reason: .paramsError))
               return nil
           }
           
           let data = Data([0x6f,0x56,0x70,0x02,0x00,0x00,0x00,0x8f])
           return BLECenter.shared.send(data: data, recvCount: Int(num), dataArrayCallback: { (datas, err) in
               if let error = err {
                   callback?(nil, error)
               }
               else {
                
                let sleeps = Sleep.pointerRedirectToParse(origin: datas)
                
                callback?((sleeps as? Array<Sleep>), nil)
                
               }
           }, toDeviceName: deviceName)
    }
}
