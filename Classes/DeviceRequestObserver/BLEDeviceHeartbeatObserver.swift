//
//  BLEDeviceHeartbeatObserver.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/12/12.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class BLEDeviceHeartbeatObserver: BLEDeviceReuqestObserver {
    
    override init() {
        super.init()
    }

    public var operation:() -> Void = {};
    
    override func didReceiveDeviceRequest(device: BLEDevice, data: Data, cmd: Data, type: Data) {
//        let cmd:Data = data[1...1]
        if cmd.uint == 0xD9 {
            operation()
        }
    }
}
