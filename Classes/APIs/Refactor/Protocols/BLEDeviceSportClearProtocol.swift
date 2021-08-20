//
//  BLEDeviceSportClearProtocol.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2020/4/1.
//  Copyright © 2020 ss. All rights reserved.
//

import Foundation
public protocol BLEDeviceSportClearProtocol {
    func deleteSportDatas(callback:BoolCallback?, toDeviceName deviceName:String?)->BLETask?
}

public extension BLEDeviceSportClearProtocol {
    func deleteSportDatas(callback:BoolCallback?, toDeviceName deviceName:String? = nil)->BLETask? {
        let data = Data([0x6f,0x53,0x71,0x01,0x00,0x00,0x8F])
        return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
}
