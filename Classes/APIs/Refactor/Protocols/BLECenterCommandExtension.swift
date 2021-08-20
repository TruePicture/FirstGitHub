//
//  BLECenterCommandExtension.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2020/2/27.
//  Copyright © 2020 ss. All rights reserved.
//

import Foundation

typealias BLECommandProtocol = BLEFactoryOnlyProtocol &
    BLEDeviceCtrlProtocol &
    BLEDevicePointerCtrlProtocol &
    BLEDeviceResetProtocol &
    BLEDeviceSyncSportProtocol &
    BLEDeviceSyncSleepProtocol &
    BLEDeviceSportSleepNumProtocol &
    BLEDeviceSportClearProtocol &
    BLEDeviceSleepClearProtocol &
    BLEDeviceStepProtocol &
    BLEDeviceTimeProtocol

extension BLECenter:BLECommandProtocol
{

     
}
