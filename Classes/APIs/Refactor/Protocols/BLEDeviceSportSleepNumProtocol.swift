//
//  BLEDeviceSportSleepNumProtocol.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2020/4/1.
//  Copyright © 2020 ss. All rights reserved.
//

import Foundation
public protocol BLEDeviceSportSleepNumProtocol {
    func getSportSleepDataNum(callback:((UInt16, UInt16, BLEError?)->Void)?, toDeviceName deviceName:String?)->BLETask?
}

public extension BLEDeviceSportSleepNumProtocol {
    func getSportSleepDataNum(callback:((UInt16, UInt16, BLEError?)->Void)?, toDeviceName deviceName:String? = nil)->BLETask? {
        let data = Data([0x6f,0x52,0x70,0x01,0x00,0x00,0x8f])
        
        print("the ggg deviceName is \(String(describing: deviceName))")
        return BLECenter.shared.send(data: data, dataArrayCallback: { (datas, err) in
                if let error = err {
                    callback?(0, 0, error)
                } else {
                    guard let ds = datas, ds.count > 0, ds[0].count >= 4 else {
                        callback?(0, 0, BLEError.taskError(reason: .dataError))
                        return
                    }
    //                let bytes = ds[0].bytes
    //                let sportNum = UInt(bytes[0]) + UInt((bytes[1] << 8))
    //                let sleepNum = UInt(bytes[2]) + UInt((bytes[3] << 8))
                    let sportNum = ds[0][0...1].uint16
                    let sleepNum = ds[0][2...3].uint16

                    callback?(sportNum, sleepNum, nil)
                }
            }, toDeviceName: deviceName)
        }
}
