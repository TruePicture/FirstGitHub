//
//  BLEDeviceSleepClearProtocol.swift
//
//
//  Created by guotonglin on 2020/8/13.
//

import Foundation


public protocol BLEDeviceSleepClearProtocol {
    func deleteSleepDatas(callback:BoolCallback?, toDeviceName deviceName:String?)->BLETask?
}

public extension BLEDeviceSleepClearProtocol {
    func deleteSleepDatas(callback:BoolCallback?, toDeviceName deviceName:String? = nil)->BLETask? {
        let data = Data([0x6f,0x55,0x71,0x01,0x00,0x00,0x8F])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
}
