//
//  OtaConfig.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

// 这里的 Apollo 是指 Apollo3 ，之前 Apollo2 没有，还是要区别开
public enum OtaPlatform: Int, Codable {
    case apollo
    case nordic
    case tlsr
}

public struct OtaConfig: Codable {

    public var id = 0
    public var platform: OtaPlatform = .apollo
    public var createTime: TimeInterval = Date().timeIntervalSince1970
    public var name = ""
    public var type = ""
    public var batchId = ""
    public var prefix = ""
    public var deviceName = ""
    public var deviceNamePrefix = ""
    public var signalMin = -100
    public var upgradeCountMax = 5
    public var otaCount = 0
    public var needReset = false
    public var firmwares: [Firmware] = []
    
    public var otaBleName: String?
    public var targetDeviceType: String?
    
    public var blePrefixAfterOTA: String?
    
    public init() {
        
    }
    
    public func getFirmwares(byType type: OtaDataType) -> [Firmware] {
        var arr = [Firmware]()
        for fm in firmwares {
            if fm.type == type {
                arr.append(fm)
            }
        }
        return arr
    }
    
    public func copyConfig() -> OtaConfig {
        var newConfig = OtaConfig()
        
        newConfig.id = self.id
        newConfig.platform = self.platform
        newConfig.createTime = self.createTime
        newConfig.name = self.name
        newConfig.type = self.type
        newConfig.batchId = self.batchId
        newConfig.prefix = self.prefix
        newConfig.deviceName = self.deviceName
        newConfig.deviceNamePrefix = self.deviceNamePrefix
        newConfig.signalMin = self.signalMin
        newConfig.upgradeCountMax = self.upgradeCountMax
        newConfig.otaCount = self.otaCount
        newConfig.needReset = self.needReset
        newConfig.firmwares = self.firmwares
        newConfig.otaBleName = self.otaBleName
        newConfig.targetDeviceType = self.targetDeviceType

        return newConfig
    }
    
}
