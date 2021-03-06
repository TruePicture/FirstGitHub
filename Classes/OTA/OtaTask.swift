//
//  OtaTask.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/11.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

// BLEKey.device, BLEKey.data, BLEKey.task
public let kOtaTaskReadyNotification = Notification.Name("kOtaTaskReadyNotification")
public let kOtaTaskFailedNotification = Notification.Name("kOtaTaskFailedNotification")
public let kOtaTaskFinishNotification = Notification.Name("kOtaTaskFinishNotification")
public let kOtaTaskProgressUpdateNotification = Notification.Name("kOtaTaskProgressUpdateNotification")

public enum OtaTaskState: Int, Codable {
    case plain = 0
    case otaing
    case cancel
    case failed
    case finish
}

public class OtaTask: NSObject, BLEDeviceDelegate {
    
    let timeout: TimeInterval = 30
    
    public var device: BLEDevice
    public var otaBleName: String
    public var otaDatas: [OtaDataModel] {
        willSet {
            
        }
        didSet {
            if otaDatas.count == 0 {
                print("出事了")
            }
             print("\(otaDatas)");
        }
    }
    public var readyCallback: EmptyBlock?
    public var progressCallback: FloatCallback?
    public var finishCallback: BoolCallback?
    
    public var state: OtaTaskState = .plain
    public var error: BLEError?
    
    public var config: OtaConfig?
    
    public var sendLength = 0
    public var totalLength = 1
    public var progress: Float {
        get {
            return Float(sendLength) / Float(totalLength)
        }
    }
    
    public var otaTimer: Timer?
    
    deinit {
        print("task deinit")
        cleanUp()
    }
    
    init(device: BLEDevice,
         otaBleName: String,
         otaDatas: [OtaDataModel],
         readyCallback: EmptyBlock?,
         progressCallback: FloatCallback?,
         finishCallback: BoolCallback?) {
        self.device = device
        self.otaBleName = otaBleName
        self.otaDatas = otaDatas
        self.readyCallback = readyCallback
        self.progressCallback = progressCallback
        self.finishCallback = finishCallback
        
        super.init()
        // 此处不能设置delegate给self，不然Apollo平台会升级失败
//        self.device.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceDataUpdate(notification:)), name: BLEInnerNotification.deviceDataUpdate, object: nil)
    }
    
    public func start() {
        if device.state == .disconnected {
            otaFailed(error: BLEError.deviceError(reason: .disconnected))
            return
        }
        
        if otaDatas.count == 0 {
            otaFailed(error: BLEError.taskError(reason: .paramsError))
            return
        }
        
        DispatchQueue.global().async {
            var tmpArr = [OtaDataModel]()
            for dm in self.otaDatas
            {
                if !dm.getApolloDataReady() {
                    let err = BLEError.taskError(reason: .paramsError)
                    self.otaFailed(error: err)
                    return
                }
                tmpArr.append(dm)
            }
            self.otaDatas = tmpArr
            DispatchQueue.main.async {
                self.enterUpgradeMode()
            }
        }
        
    }
    
    public func cancel() {
        state = .cancel
    }
    
    public func checkIsCancel() -> Bool {
        if state == .cancel {
            let error = BLEError.taskError(reason: .cancel)
            otaFailed(error: error)
            return true
        }
        return false
    }
    
    
    private func enterUpgradeMode() {
        if device.isApollo3 {
            startOta()
        } else {
            let addressData = otaDatas[0].otaAddressData
            sendOtaAddress(addressData: addressData!)
        }
    }
    
    private func sendOtaAddress(addressData: Data) {
        print("开始发送地址：\(device.name)")
        var data = Data([0x6F,0x0E,0x71,5,0x00,0x00])
        data.append(addressData)
        data.append([0x8f], count: 1)
        weak var weakSelf = self
        _ = BLECenter.shared.send(data: data, boolCallback: { (b, err) in
            print("发送地址信息之后回调：\(self.device.name)")
            if err != nil {
                self.otaFailed(error: err!)
                return
            }
            weakSelf?.connectOtaDevice()
        }, toDeviceName: device.name)
    }
    
    private func connectOtaDevice() {
        print("ota 设备名称：\(otaBleName)")
        BLECenter.shared.connect(deviceName: otaBleName, callback: { (bd, err) in
            if err != nil {
                self.otaFailed(error: err!)
                return
            }
            self.device = bd!
//            self.device.delegate = self
            self.startOta()
        }, timeout: 60)
    }
    
    private func startOta() {
        
//        self.device.delegate = self
        
        otaReady()
        
        
        var length = 0
        for dm in otaDatas {
            length += dm.otaData.count
        }
        sendLength = 0
        totalLength = length
        sendOtaDataLength(length: length)
    }
    
    // 发送ota数据总长度
    private func sendOtaDataLength(length: Int) {
        addTimer(timeout: timeout, action: 1)
        var data = Data([0x01])
        var len = length
        data.append(bytes: &len, count: 4)
        writeDataToNotify(data)
    }
    
    
    private func sendOtaSettingData()
    {
        addTimer(timeout: timeout, action: 2)
        guard otaDatas.count > 0, otaDatas[0].crcData.count > 0, otaDatas[0].otaAddressData.count >= 4 else {
            return
        }
        let dm = otaDatas[0]
//        let addressBytes = dm.otaAddressData.bytes
//        if addressBytes[0] == 0 &&
//            addressBytes[1] == 0 &&
//            addressBytes[2] == 0 &&
//            addressBytes[3] == 0 {
//            print("ota 数据包的地址不对")
//            let err = BLEError.taskError(reason: .paramsError)
//            otaFailed(error: err)
//            return
//        }
        
        var settingData = Data()
        
        var length = dm.otaData.count
        var type = dm.type.rawValue
        var action:UInt8 = 2
        var numLength = kPackageCountCallback
        
        settingData.append(bytes: &action, count: 1)
        settingData.append(bytes: &type, count: 1)
        settingData.append(dm.otaAddressData)
        settingData.append(bytes:&length, count: 4)
        settingData.append(dm.crcData)
        settingData.append(bytes: &numLength, count:1)
        
        
//        print("发送ota设置数据：\(settingData.hexEncodedString())")
        
        writeDataToNotify(settingData)
    }
    
    // 第三步、发送数据包、每2K数据会有回调一次，所以整包都先拆分2K
    // 每包又分成20一个的package
    // 每次最多发送20个package，等带设备同步回调
    private func sendPackages() {
        addTimer(timeout: timeout, action: 3)
//        print("sendPackages:")
        guard otaDatas.count > 0, otaDatas[0].sections.count > 0 else {
            return
        }
        
        DispatchQueue.global().async {
            let section = self.otaDatas[0].sections[0]
            
            let sendMaxCount = min(section.totalPackageCount, section.currentPackageIndex + kPackageCountCallback)
            
            if section.currentPackageIndex >= sendMaxCount {
                return
            }
            
            for i in section.currentPackageIndex ..< sendMaxCount {
                let data = section.sectionData.subdata(in: section.packageList[i])
                //            print("package(\(i))data: \(data.hexEncodedString())")
                self.writeData(data)
                self.sendLength += data.count
                
                self.otaProgressUpdate()
            }
        }
    }
    
    private func sendCheckCrc() {
        let data = Data([0x04])
        writeDataToNotify(data)
        addTimer(timeout: timeout, action: 4)
    }
    
    private func sendEndOta() {
        let data = Data([0x05])
        writeDataToNotify(data)
        addTimer(timeout: timeout, action: 5)
    }
    
    func otaReady() {
        DispatchQueue.main.async {
            self.device.isOTAing = true
            self.state = .otaing
            self.readyCallback?()
            NotificationCenter.default.post(name: kOtaTaskReadyNotification, object: nil, userInfo: [BLEKey.task: self])
        }
    }
    
    func otaProgressUpdate() {
        // 进度回调
        DispatchQueue.main.async {
            self.progressCallback?(self.progress)
            NotificationCenter.default.post(name: kOtaTaskProgressUpdateNotification, object: nil, userInfo: [BLEKey.task: self])
        }
    }
    
    func otaFailed(error: BLEError) {
        
        print("ota failed:\(device.name), reason:\(error)")
        
        DispatchQueue.main.async {
            self.error = error
            self.state = .failed
            self.device.isOTAing = false
            self.finishCallback?(false, error)
            self.cleanUp()
            NotificationCenter.default.post(name: kOtaTaskFailedNotification, object: nil, userInfo: [BLEKey.task: self, "error": error])
        }
    }
    
    func otaFinish() {
        DispatchQueue.main.async {
            self.state = .finish
            self.device.isOTAing = false
            self.finishCallback?(true, nil)
            self.cleanUp()
            NotificationCenter.default.post(name: kOtaTaskFinishNotification, object: nil, userInfo: [BLEKey.task: self])
        }
    }
    
    
    // MARK: - 写数据
    private func writeData(_ data: Data) {
        if checkIsCancel() {
            return
        }
        print("\(device.name)，发送（\(UUID.otaWriteC)）:\(data.hexEncodedString())")
        _ = device.write(data, characteristicUUID: UUID.otaWriteC)
        guard let conf = self.config else {
            return
        }
        if !device.isApollo3 {
            if conf.upgradeCountMax > 1 {
                Thread.sleep(forTimeInterval: (0.001 * Double(conf.upgradeCountMax)))
            }
        }
//        Thread.sleep(forTimeInterval: 0.002)
    }
    
    private func writeDataToNotify(_ data: Data) {
        if checkIsCancel() {
            return
        }
        
        if data[0] == 02 {
            print("TES")
        }
        
        print("发送（\(UUID.otaNotifyC)）:\(data.hexEncodedString())")
        _ = device.write(data, characteristicUUID: UUID.otaNotifyC)
    }
    
    
    // MARK: - 定时器
    func addTimer(timeout: TimeInterval, action: Int) {
        removeTimer()
        otaTimer = Timer(timeInterval: timeout, target: self, selector: #selector(handleTimeout(timer:)), userInfo: ["action": action], repeats: false)
        otaTimer!.fireDate = Date(timeIntervalSinceNow: timeout)
        RunLoop.main.add(otaTimer!, forMode: .common)
    }
    
    func removeTimer() {
        otaTimer?.invalidate()
        otaTimer = nil
    }
    
    @objc private func handleTimeout(timer: Timer) {
        removeTimer()
        readyCallback = nil
        progressCallback = nil
        let err = BLEError.taskError(reason: .timeout)
        otaFailed(error: err)
    }
    
    func cleanUp() {
        readyCallback = nil
        progressCallback = nil
        finishCallback = nil
        otaDatas.removeAll()
        NotificationCenter.default.removeObserver(self, name: BLEInnerNotification.deviceDataUpdate, object: nil)
        removeTimer()
    }
    
    // MARK: - 接收数据
    public func deviceDidUpdateData(data: Data, deviceName: String, uuid: String) {
        if deviceName != self.device.name || uuid != UUID.otaNotifyC || data.count < 2 {
            print("不符合要求？？？？？？？")
            return
        }
        otaDeviceDataComes(data: data)
    }
    
    @objc func deviceDataUpdate(notification: Notification?) {
//        print("deviceUpdate: \(String(describing: notification?.userInfo))")
        guard let de = notification?.userInfo?[BLEKey.device] as? BLEDevice, de == self.device else {
            return
        }

        guard let uuid = notification?.userInfo?[BLEKey.uuid] as? String, uuid == UUID.otaNotifyC else {
            return
        }

        guard let data = notification?.userInfo?[BLEKey.data] as? Data, data.count >= 2 else {
            return
        }
        deviceDidUpdateData(data: data, deviceName: de.name, uuid: uuid)
    }
    
    private func otaDeviceDataComes(data: Data) {
        print("来数据了：\(data.hexEncodedString())")
        removeTimer()
        // 命令
        let cmd = data.bytes[0]
        // 成功与否：1成功、0失败
        let flag = data.bytes[1]
        if flag == 0 {
            let err = BLEError.taskError(reason: .dataError)
            otaFailed(error: err)
        }
        else {
            switch cmd {
            case 1:
                // （发送ota长度成功之后回调这个）进入ota成功，开始发送ota设置信息
                //                print("设备回传1，开始发送ota配置数据")
                sendOtaSettingData()
            case 2:
                //                print("设备回传2，开始发送包数据")
                sendPackages()
            case 3:
                /*
                 第3个字节：
                 查询类型
                 0x01：指定包数回传
                 0x02：2k回传
                 0x03：手机查询
                 0x04：单个bin数据接收完成
                 */
                let type = data.bytes[2]
                if type == 4 {
                    //                    print("设备回传3-4，说明一包传输完成了，开始发送crc")
                    sendCheckCrc()
                } else if type == 2 {
                    // 移除一个数据分区
                    //                    print("移除一个分区，开始下发下一个包")
                    if otaDatas.count == 0 {
                        return
                    }
                    otaDatas[0].sections.remove(at: 0)
                    // 继续发送下一个数据分区
                    sendPackages()
                } else {
                    //                    print("开始下发下一个回传包")
                    if otaDatas.count == 0 {
                        return
                    }
                    otaDatas[0].sections[0].currentPackageIndex += kPackageCountCallback
                    sendPackages()
                }
            case 4:
                // crc 校验成功
                //                print("crc校验成功")
                if otaDatas.count > 0 {
                    otaDatas.remove(at: 0)
                }
                // 发送下一个固件
                if otaDatas.count > 0 {
                    sendOtaSettingData()
                } else {
                    sendEndOta()
                }
            case 5:
                otaFinish()
            default:
                print("ota callback unknown cmd")
            }
        }
    }
    
    
    public static func == (lhs: OtaTask, rhs: OtaTask) -> Bool {
        return lhs.device.name == rhs.device.name
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? OtaTask else {
            return false
        }
        return self.device.name == other.device.name
    }
    
}
