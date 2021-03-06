//
//  BLETask.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/9.
//  Copyright © 2018年 ss. All rights reserved.
//

import UIKit

public enum BLETaskState {
    case plain
    case start
    case cancel
    case failed
    case success
}

@objcMembers public class BLETask: NSObject {
    var timer:Timer?
    var state:BLETaskState = .plain
    var error:BLEError?
    var timeout:TimeInterval = kDefaultTimeout
    var ob:NSKeyValueObservation?
    var startTimeInterval: TimeInterval = Date().timeIntervalSince1970
    
    var isTimeout: Bool {
        get {
            let now = Date().timeIntervalSince1970
            return (now - startTimeInterval >= timeout)
        }
    }
    
    func start() {
        self.state = .start
        startTimer()
    }
    
    func cancel() {
        self.state = .cancel
    }
    
    func startTimer() {
        self.stopTimer()
        DispatchQueue.main.async {
            self.timer = Timer(timeInterval: self.timeout, target: self, selector: #selector(self.timeoutHandler), userInfo: nil, repeats: false)
            self.timer!.fireDate = Date(timeIntervalSinceNow: self.timeout)
            RunLoop.main.add(self.timer!, forMode: .common)
        }
    }
    
    func stopTimer() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil;
        }
    }
    
    @objc func timeoutHandler() {
        self.state = .failed
    }
}

public class BLEScanTask: BLETask {
    var priority = 0
    var isConnectScan = false
    var scanCallback: ScanBlock?
    var stopCallback: EmptyBlock?
    var taskID: String
    
    public init(taskID: String, scanCallback: ScanBlock?, stopCallback: EmptyBlock?) {
        self.taskID = taskID
        self.scanCallback = scanCallback
        self.stopCallback = stopCallback
    }
    
    override public var hash: Int {
        return self.taskID.hash
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? BLEScanTask else {
            return false
        }
        return self.taskID == other.taskID
    }
}


@objcMembers public class BLEConnectTask: BLETask {
    var deviceName:String?
    var device:BLEDevice?
    var connectBlock:ConnectBlock?
    var isDisconnect = false
    var isConnecting = false
    
    var name:String? {
        return self.device?.name ?? self.deviceName;
    }
    
    deinit {
        connectBlock = nil
        ob = nil
    }
    
    init(deviceName:String, connectBlock:ConnectBlock?, timeout:TimeInterval = kDefaultTimeout) {
        super.init()
        self.deviceName = deviceName
        self.timeout = timeout
        self.connectBlock = connectBlock
    }
    
    init(device:BLEDevice, connectBlock:ConnectBlock?, timeout:TimeInterval = kDefaultTimeout) {
        super.init()
        self.device = device
        self.timeout = timeout
        self.connectBlock = connectBlock
    }
    
    func connectFailed(err: BLEError) {
        error = err
        device = nil
        state = .failed
        isConnecting = false
        stopTimer()
    }
    
    func connectSuccess() {
        error = nil
        device!.state = .ready
        state = .success
        isConnecting = false
        stopTimer()
    }
    
    override func timeoutHandler() {
        super.timeoutHandler()
        connectFailed(err: BLEError.taskError(reason: .timeout))
        BLEDevicesManager.shared.deviceConnectTimeout(withTask: self)
    }
    
    override public var hash: Int {
        return self.name?.hash ?? 0
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? BLEConnectTask else {
            return false
        }
        return self.name == other.name
    }
}


// MARK: - Data Task
@objcMembers public class BLEDataTask: BLETask, BLEDataParserProtocol {
    var device:BLEDevice?
    var data:BLEData
    var callback:CommonCallback?
    
    var parser:BLEDataParser!
    
//    var name:String? {
//        return self.device?.name ?? self.deviceName;
//    }
    private var stateOb : NSKeyValueObservation?
    
    deinit {
        stateOb = nil
        callback = nil
        ob = nil
    }
    
    init(data:BLEData) {
        self.data = data
        super.init()
    }
    
    init(device:BLEDevice, data:BLEData, callback:CommonCallback?, timeout:TimeInterval = kDefaultTimeout) {
        self.data = data
        self.device = device
        self.callback = callback
        super.init()
        self.timeout = timeout
        
        self.parser = BLEDataParser()
        self.parser.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDataUpdate), name: BLEInnerNotification.deviceDataUpdate, object: nil)
        
        // 监听
        weak var weakSelf = self
        stateOb = data.observe(\BLEData.stateRaw) { (bleData, change) in
//            print("hello")
            switch bleData.state {
            case .plain:
                return
            case .sending:
                return
            case .sent:
                return
            case .sendFailed:
                let error = weakSelf?.data.error
                weakSelf?.error = error ?? BLEError.taskError(reason: .sendFailed)
                weakSelf?.state = .failed
                weakSelf?.device = nil
                weakSelf?.data.recvData = nil
                weakSelf?.data.recvDatas = nil
                weakSelf?.parser.clear()
            case .recvFailed:
                let error = weakSelf?.data.error
                weakSelf?.error = error ?? BLEError.taskError(reason: .dataError)
                weakSelf?.state = .failed
                weakSelf?.device = nil
                weakSelf?.data.recvData = nil
                weakSelf?.data.recvDatas = nil
                weakSelf?.parser.clear()
            case .recving:
                return
            case .recved:
                weakSelf?.error = nil
                weakSelf?.state = .success
                weakSelf?.parser.clear()
            case .timeout:
                let error = BLEError.taskError(reason: .timeout)
                weakSelf?.error = error
                weakSelf?.state = .failed
                weakSelf?.device = nil
                weakSelf?.data.recvData = nil
                weakSelf?.data.recvDatas = nil
                weakSelf?.parser.clear()
            }
            weakSelf?.stopTimer()
            if weakSelf != nil {
                NotificationCenter.default.post(name: BLEInnerNotification.taskFinish, object: nil, userInfo: [BLEKey.task : weakSelf!])
            }
        }
    }
    
    override func start() {
        super.start()
        
        parser.clear()
        
        data.state = .sending
        
        if data.sendToUuid == nil {
            guard let uuid = BLEConfig.shared.sendUUID[data.type] else {
                data.error = BLEError.deviceError(reason: .noCharacteristics)
                data.state = .sendFailed
                return
            }
            data.sendToUuid = uuid
            
            let recvUuid = BLEConfig.shared.recvUUID[data.type]
            data.recvFromUuid = recvUuid
        }
        
        
        guard let sendDevice = device else {
            data.error = BLEError.deviceError(reason: .disconnected)
            data.state = .sendFailed
            return
        }
        
        if data.sendData == Data([0x6f,0x01,0x81,0x02,0x00,0xd9,0x00,0x8f]) {
            print("get 将要写入");
        }
        
        let canWrite = sendDevice.write(data.sendData, characteristicUUID: data.sendToUuid!)
        
        if !canWrite {
            data.error = BLEError.deviceError(reason: .disconnected)
            data.state = .sendFailed
        } else {
            if BLEConfig.shared.shouldSend03End && data.recvFromUuid != nil {
                _ = sendDevice.write(Data([0x03]), characteristicUUID: data.recvFromUuid!)
            }
            
            if self.data.type == BLEDataType.response {
                data.state = .recved
            }
            else {
                data.state = .sent
            }
        }
    }
    
    override func startTimer() {
        // 回复设备主动发来的请求没有超时
        if self.data.type == BLEDataType.response {
            return
        }
        else {
            super.startTimer();
        }
    }
    
    @objc func deviceDataUpdate(notification: Notification) {
        guard let uuid = notification.userInfo?[BLEKey.uuid] as? String else {
            return
        }
        guard let data = notification.userInfo?[BLEKey.data] as? Data else {
            return
        }
        
        guard let device = notification.userInfo?[BLEKey.device] as? BLEDevice else {
            return
        }
        
        if uuid == self.data.recvFromUuid && device == self.device {
            startTimer()
            parser.standardParse(data: data, sendData: self.data.sendData, recvCount: self.data.recvDataCount)
        }
        
    }

    override func timeoutHandler() {
        super.timeoutHandler()
        if self.data.state == .timeout ||
            self.data.state == .sendFailed ||
            self.data.state == .recvFailed {
            return
        }
        // 在kvo里面处理
        self.data.state = .timeout
    }
    
    /// MARK: - 代理实现
    func didFinishParser(data: Data, dataArr: Array<Data>, recvCount: Int) {
        // kvo 里面处理完成任务
        if self.data.recvDataCount == recvCount {
            self.data.recvDatas = dataArr
            self.data.recvData = data
            self.data.state = .recved
        } else {
            self.data.state = .recvFailed
        }
    }
    
}
