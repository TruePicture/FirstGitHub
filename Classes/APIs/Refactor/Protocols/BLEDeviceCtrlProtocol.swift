//
//  BLEDeviceCtrlProtocol.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2020/3/9.
//  Copyright © 2020 ss. All rights reserved.
//

import Foundation
public protocol BLEDeviceCtrlProtocol {
    func cancelPairCommand(callback:BoolCallback?, toDeviceName deviceName:String) -> BLETask?
}

public extension BLEDeviceCtrlProtocol {
    func cancelPairCommand(callback:BoolCallback?, toDeviceName deviceName:String) -> BLETask? {
           let data = Data([0x6f, 0x1A, 0x71, 0x01, 0x00, 0x16, 0x8f])
           return BLECenter.shared.send(data: data, boolCallback: callback, toDeviceName: deviceName)
    }
}
