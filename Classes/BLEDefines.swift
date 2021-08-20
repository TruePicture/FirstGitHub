//
//  Defines.swift
//  BLE-Swift
//
//  Copyright © 2018年 ss. All rights reserved.
//

import Foundation

// MARK: - 常量定义
public let kDefaultTimeout:TimeInterval = 15
public let kConnectTimeout:TimeInterval = 15
public let kScanTimeout:TimeInterval = 10


// MARK: - 闭包定义
public typealias GetReadyBlock = (BLEError?)->Void
public typealias WriteBlock = (BLEError?)->Void
public typealias ScanBlock = (Array<BLEDevice>?, BLEError?)->Void
public typealias ConnectBlock = (BLEDevice?, BLEError?)->Void
public typealias EmptyBlock = ()->Void
public typealias CommonCallback = (Any?, BLEError?)->Void
public typealias BoolCallback = (Bool, BLEError?)->Void
public typealias DataArrayCallback = (Array<Data>?, BLEError?)->Void
public typealias StringCallback = (String?, BLEError?)->Void
public typealias IntCallback = (Int, BLEError?)->Void
public typealias DictArrayCallback = (Array<Dictionary<String, Any>>?, BLEError?)->Void
public typealias FloatCallback = (Float)->Void


// MARK: - 错误码定义
public struct Code {
    public static let bleUnavaiable = 9
    public static let blePowerOff = 10
    public static let deviceDisconnected = 13
    public static let noServices = 11
    public static let failToConnect = 99
    public static let failToDisconnect = 98
    public static let noCharacteristics = 12
    public static let sendFailed = 15
    public static let timeout = 20
    public static let repeatOperation = 30
    public static let paramsError = 40
    public static let dataError = 50
}

public struct Domain {
    static let device = "BLEDevice"
    static let center = "BLECenter"
    static let data = "BLEData"
}

/// 键值对的健
public struct BLEKey {
    public static let state = "BLEKey.state"
    public static let device = "BLEKey.device"
    public static let connectTask = "BLEKey.connectTask"
    public static let task = "BLEKey.task"
    public static let data = "BLEKey.data"
    public static let uuid = "BLEKey.uuid"
    public static let rssi = "BLEKey.rssi"
    public static let error = "BLEKey.error"
}

// MARK: - 服务特征ID
public struct UUID {
    public static let mainService = "6006"
    public static let c8001 = "8001"
    public static let c8002 = "8002"
    public static let c8003 = "8003"
    public static let c8004 = "8004"
    
    public static let c2A37 = "2A37"
    
    public static let otaService = "1530"
    public static let otaNotifyC = "1531"
    public static let otaWriteC = "1532"
    
    public static let nordicDFUService = "00001530-1212-EFDE-1523-785FEABCD123"
    public static let nordicOtaBat = "00001531-1212-EFDE-1523-785FEABCD123"
    public static let nordicOtaBin = "00001532-1212-EFDE-1523-785FEABCD123"
    public static let nordicVersion = "00001534-1212-EFDE-1523-785FEABCD123"
    
    public static let tlsrOtaUuid = "00010203-0405-0607-0809-0A0B0C0D2B12"
    
    public static let algorithmCollectionService = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    public static let algorithmCollectionConfigureChannel = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    public static let algorithmCollectionDataChannel1 = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    public static let algorithmCollectionDataChannel2 = "6E400004-B5A3-F393-E0A9-E50E24DCCA9E"
    
}

// MARK: - 常量定义
/// 通知的常量
public struct BLENotification {
    
    /// 发送通知 userInfo 带 [BLEKey.state : CBManagerState]
    public static let stateChanged = NSNotification.Name(rawValue: "BLENotification.stateChanged")
    public static let deviceConnected = NSNotification.Name(rawValue: "BLENotification.deviceConnected")
    public static let deviceDisconnected = NSNotification.Name(rawValue: "BLENotification.deviceDisconnected")
    public static let deviceRssiUpdate = NSNotification.Name(rawValue: "BLENotification.deviceRssiUpdate")
}

public struct BLEInnerNotification {
    
    /// userInfo: BLEKey.device : Device
    public static let deviceConnected = NSNotification.Name("BLECenterNotification.deviceConnected")
    
    /// userInfo: BLEKey.connectTask : ConnectTask
    public static let deviceReady = NSNotification.Name("BLECenterNotification.deviceReady")
    
    /// userInfo: BLEKey.device : CBPeripheral
//    static let deviceDisonnected = NSNotification.Name("BLECenterNotification.deviceDisconnected")
    
    /// userInfo: BLEKey.task : BLETask
    public static let taskFinish = NSNotification.Name("BLECenterNotification.taskFinish")
    
    /// userInfo: BLEKey.uuid : String;  BLEKey.data : Data;
    /// BLEKey.device: BLEDevice
    public static let deviceDataUpdate = NSNotification.Name("BLECenterNotification.deviceDataUpdate")
    
    /// userInfo: BLEKey.data : Data
    public static let c8004DataComes = NSNotification.Name("BLECenterNotification.c8004DataComes")
}
