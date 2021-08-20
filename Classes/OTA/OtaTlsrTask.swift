//
//  OtaTlsrTask.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/2/13.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class OtaTlsrTask: OtaTask {
    
    
    private var telinkData   : Data!
    
    // 当前升级项 2k 切分后的集合
    private var splitDataArray : Array<Data>?
    
    // 正在升级
    private var isUpgrading: Bool = false
    
    // 升级过程中 回调
    
    // 需要停止ota
    private var needStopWriteData: Bool = false
    
    // 等待设备确认通知
    private var confirm: Bool = false
    
    // 每1k Package中 发送的第几次
    private var currentWriteNumber: Int = 0
    
    //每1k 总共需要发送的次数
    private var totalPackageNumber: Int = 0
    
    //累计所有次数，正在发送的次数
    private var totalWritedNumber: Int = 0
    
    //最后一包大小
    private var remainByteNumber :Int = 0
    
    //已发送的总包数 保存进度
    private var writedNumber: Int = 0
    
    
    
    private var isSingleOTAFinish = false

    private let serial = DispatchQueue(label: "serialQueue1")
    
    private let heartbeatObserver = BLEDeviceHeartbeatObserver.init()
    
    override init(device: BLEDevice, otaBleName: String, otaDatas: [OtaDataModel], readyCallback: EmptyBlock?, progressCallback: FloatCallback?, finishCallback: BoolCallback?) {
        super.init(device: device, otaBleName: otaBleName, otaDatas: otaDatas, readyCallback: readyCallback, progressCallback: progressCallback, finishCallback: finishCallback);
        self.device.delegate = self
        
        self.splitDataArray = []
    }
    
    private func otaDeviceDataComes(data: Data) {
        
    }
    
    override func start() {
        
        guard device.state == .ready else {
            otaFailed(error: BLEError.deviceError(reason: .disconnected))
            return
        }
        
        guard otaDatas.count > 0 else {
            otaFailed(error: BLEError.taskError(reason: .paramsError))
            return
        }
        
        heartbeatObserver.operation = {
            print("收到心跳包 并且回复设备")
            let _ = BLECenter.shared.responseToHeatbeat(boolCallback: { (result, error) in
                if result {
                    print("回复心跳包成功")
                }
            }, toDeviceName: self.device.name)
        }
        
        // 有且仅有一个
        self.telinkData = otaDatas.first!.data
        // 切割
        self.splitData(data: self.telinkData)
        
        self.totalLength = self.telinkData.count
        
        self.beginWrite()
    }
    
    private func beginWrite() {
        let buf = Data([0x01, 0xff])
        writeData(data: buf)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.writeBinData(true)
        }
    }
    
//     func start2() {
//
//        if device.state == .disconnected {
//            otaFailed(error: BLEError.deviceError(reason: .disconnected))
//            return
//        }
//
//        if otaDatas.count == 0 {
//            otaFailed(error: BLEError.taskError(reason: .paramsError))
//            return
//        }
//
//        heartbeatObserver.operation = {
//            print("收到心跳包 并且回复设备")
//            let _ = BLECenter.shared.responseToHeatbeat(boolCallback: nil, toDeviceName: self.device.name)
//        }
//
//        var tmpArr = [OtaDataModel]()
//
//        for dm in otaDatas
//        {
//            if !dm.getTlsrDataReady() {
//                let err = BLEError.taskError(reason: .paramsError)
//                self.otaFailed(error: err)
//                return
//            }
//            tmpArr.append(dm)
//        }
//        otaDatas = tmpArr
//        self.beginWrite()
//
//    }
    

    
//    private func startOta() {
//        otaReady()
//
//        let dm = otaDatas[0]
//        startSendOtaData(dataModel: dm)
//    }
    
//    private func startSendOtaData(dataModel: OtaDataModel) {
//
//        if self.state == .failed {
//            return
//        }
//
//        serial.async {
//            self.totalLength = dataModel.tlsrOtaDataPackages.count
//
//            // 发64个包校验一次
//            let sendCountPerRead:Int = 1024 / 16
//
//            for _ in 0 ..< sendCountPerRead {
//
//                self.sendLength = dataModel.tlsrOtaDataIndex + 1
//
////                print("index:\(dataModel.tlsrOtaDataIndex), count:\(dataModel.tlsrOtaDataPackages.count), progress:\(self.progress)")
//
//                let sd = dataModel.tlsrOtaDataPackages[dataModel.tlsrOtaDataIndex]
//                self.writeData(data: sd)
//
//                Thread.sleep(forTimeInterval: 0.01)
//
//                // 最后一包
//                if dataModel.tlsrOtaDataIndex + 1 == self.totalLength {
//                    self.isSingleOTAFinish = true
//
//                    self.readData()
//
//                    // 进度回调
//                    self.sendLength = self.totalLength
//                    DispatchQueue.main.async {
//                        self.progressCallback?(1)
//                        NotificationCenter.default.post(name: kOtaTaskProgressUpdateNotification, object: nil, userInfo: [BLEKey.task: self])
//                    }
//                    return
//                }
//                else {
//                    print("----- index:\(dataModel.tlsrOtaDataIndex) sendCountPerRead:\(sendCountPerRead)")
//
//                    DispatchQueue.main.async {
//
//                        self.progressCallback?(self.progress)
//                        NotificationCenter.default.post(name: kOtaTaskProgressUpdateNotification, object: nil, userInfo: [BLEKey.task: self])
//                    }
//
//                    if dataModel.tlsrOtaDataIndex%sendCountPerRead == sendCountPerRead - 1 {
//                        self.readData()
//                    }
//                    else {
//
//                    }
//                }
//
//                dataModel.tlsrOtaDataIndex = dataModel.tlsrOtaDataIndex + 1
//
//            }
//
//            self.addTimer(timeout: 10, action: 2)
//
//        }
//    }
    
    
//    private func endOta(dataModel: OtaDataModel) {
//
//        var adr_index:Int = Int(ceil(Double(dataModel.data.count)/16.0));
//        adr_index = adr_index - 1;
//        let lengthLowByte = adr_index % 0x100
//        let lengthHighByte = (adr_index - lengthLowByte) / 0x100 % 0x100
//
//        var buf = Data([0x02, 0xff])
//        buf.append(lengthLowByte.data(byteCount: 1))
//        buf.append(lengthHighByte.data(byteCount: 1))
//        buf.append((~lengthLowByte).data(byteCount: 1))
//        buf.append((~lengthHighByte).data(byteCount: 1))
//        writeData(data: buf)
//        otaFinish()
//    }
    
    
    func writeData(data: Data) {
        if checkIsCancel() {
            return
        }
        print("发送数据：\(data.hexEncodedString())")
        _ = self.device.write(data, characteristicUUID: UUID.tlsrOtaUuid)
    }
    
    func readData() {
        print("readData Check CRC")

        if checkIsCancel() {
            return
        }
        _ = self.device.read(characteristicUUID: UUID.tlsrOtaUuid)
    }
    
    override func deviceDataUpdate(notification: Notification?) {
        guard let de = notification?.userInfo?[BLEKey.device] as? BLEDevice, de == self.device else {
            return
        }

        guard let uuid = notification?.userInfo?[BLEKey.uuid] as? String, (uuid == UUID.c8002 || uuid == UUID.tlsrOtaUuid) else {
            return
        }

        guard let data = notification?.userInfo?[BLEKey.data] as? Data, data.count >= 1 else {
            return
        }
        deviceDidUpdateData(data: data, deviceName: de.name, uuid: uuid)
    }
    
    // MARK: - 接收数据
    override func deviceDidUpdateData(data: Data, deviceName: String, uuid: String) {
        print("设备回传：\(data.hexEncodedString())")
        
        if deviceName != self.device.name || uuid != UUID.tlsrOtaUuid {
            return
        }
        
//        if !self.isSingleOTAFinish && otaDatas.count > 0 {
//            startSendOtaData(dataModel: otaDatas[0])
//        } else {
//            endOta(dataModel: otaDatas[0]);
//        }
        
        self.deviceConfirm()
        
    }
    
}



extension OtaTlsrTask {
    
    func writeBinData(_ nextPackage: Bool) {
        if self.confirm {
            print("等待设备确认中")
            return
        }
        guard self.needStopWriteData == false else {
            print("手动停止发送数据")
            return
        }
        if let tData = self.splitDataArray?.first {
            if nextPackage {
                let dataLength = tData.count
                self.currentWriteNumber = 0
                self.remainByteNumber = dataLength % 16
                self.totalPackageNumber = dataLength / 16
            }
            if(totalPackageNumber == currentWriteNumber) {
                if self.remainByteNumber > 0 {
                    let tempRemainCount = self.remainByteNumber
                    let startIndex = tData.index(tData.startIndex, offsetBy: currentWriteNumber * 16)
                    let endIndex = tData.index(startIndex, offsetBy: tempRemainCount)
                    let subDataRange:Range = startIndex..<endIndex
                    let writeData = tData.subdata(in: subDataRange)
                    if writeData.count > 0 {
                        self.buildOtaPackage(writeData)
                        self.currentWriteNumber += 1
                        self.writedNumber += tempRemainCount
                    }
                }
                
                if self.splitDataArray!.count % 2 == 1 {
                    self.confirm = true
                } else {
                    self.deviceConfirm()
                }
                
                
            }else {
                let startIndex = tData.index(tData.startIndex, offsetBy: currentWriteNumber * 16)
                let endIndex = tData.index(startIndex, offsetBy: 16)
                let subDataRange:Range = startIndex..<endIndex
                let writeData = tData.subdata(in: subDataRange)
                self.buildOtaPackage(writeData)
                
                self.currentWriteNumber += 1
                self.writedNumber += 16
            }
            
//            if self.processCallback != nil {
//                self.processCallback!(.Nomal,.WriteDataIng,((Float(self.writedNumber)) * 1.0 / Float(telinkData.count)))
//            }
            
            DispatchQueue.main.async {
                
                // 这进度 是为了 满足 父类的进度计算
                self.sendLength = self.writedNumber
                
                // writedNumber 和 telinkData.count 是升级过程的数据
                self.progressCallback?(((Float(self.writedNumber)) * 1.0 / Float(self.telinkData.count)))
                NotificationCenter.default.post(name: kOtaTaskProgressUpdateNotification, object: nil, userInfo: [BLEKey.task: self])
            }
            
            
            if self.confirm {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    print("readValueFromeCharacteristic  \(self.totalPackageNumber)  --- \(self.currentWriteNumber)")
//                    AppsBluetoothFacade.readValueFromeCharacteristic()
                    self.readData()
                }
            }else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.007) {
                    self.writeBinData(false)
                }
            }
        }
    }
    
    
    func splitData(data: Data) {
        let dataLength = data.count
        self.splitDataArray!.removeAll()
        let splitCount = dataLength / 1024
        let lastLeft   = dataLength % 1024
        for i in 0..<splitCount {
            let startIndex = data.index(data.startIndex, offsetBy: i * 1024)
            let endIndex = data.index(startIndex, offsetBy: 1024)
            let subDataRange:Range = startIndex..<endIndex
            self.splitDataArray!.append(data.subdata(in: subDataRange))
        }
        if lastLeft > 0 {
            let startIndex = data.index(data.endIndex, offsetBy: -lastLeft)
            let subDataRange:Range = startIndex..<data.endIndex
            self.splitDataArray!.append(data.subdata(in: subDataRange))
        }
    }
    
    func getCRC(arr:[UInt8]) -> Int {
        var CRC:Int = 0x0000ffff
        let POLYNOMIAL:Int = 0x0000a001
        let length = arr.count
        for i in 0..<length {
            CRC ^= (Int(arr[i] & 0x000000ff))
            for _ in 0..<8 {
                if((CRC & 0x00000001) != 0 ) {
                    CRC >>= 1
                    CRC ^= POLYNOMIAL
                }else {
                    CRC >>= 1
                }
            }
        }
        return CRC
    }
    
    
    func buildOtaPackage(_ cdata: Data) {
        let contentBytes = [UInt8](cdata)
        var bytes: [UInt8] = Array(repeating: 0, count: 18)
        bytes[1] = UInt8((totalWritedNumber >> 8) & 0xFF);
        bytes[0] = UInt8((totalWritedNumber) & 0xFF);
        for i in 2..<18 {
            if (i < contentBytes.count + 2) {
                bytes[i] = contentBytes[i-2]
            }else {
                bytes[i] = 0xFF
            }
        }
        let crc = self.getCRC(arr: bytes)
        var crcBytes: [UInt8] = [0, 0]
        crcBytes[1] = UInt8((crc >> 8) & 0xFF);
        crcBytes[0] = UInt8((crc) & 0xFF);
        let resultBytes = bytes + crcBytes
        print("Telink Ota Send : \(resultBytes)")
        let writeData = Data.init(bytes: resultBytes, count: 20)
        
//        AppsBluetoothFacade.directWrite(data: writeData, orderType: .WithOutResponse)
        
        self.writeData(data: writeData)
        
        self.totalWritedNumber += 1
    }
    
    func deviceConfirm() {
        self.splitDataArray?.removeFirst()
        self.confirm = false
        if self.splitDataArray!.count > 0 {
            self.writeBinData(true)
        }else {
            self.writeEndOta()
            
            self.otaFinish()
        }
    }
    
    func writeEndOta() {
        print("发送结束升级")
        let binLength = self.telinkData.count
        // 总 Index
        var adr_index =  binLength % 16 == 0 ? (binLength / 16) : (binLength / 16) + 1
        adr_index -= 1
        let lengthLowByte = adr_index % 0x100 // adr_index.truncatingRemainder(dividingBy: 0x100)
        let tempNumber = (adr_index - lengthLowByte) / 0x100
        let lengthHighByte = tempNumber % 0x100 // tempNumber.truncatingRemainder(dividingBy: 0x100)
        let resultBytes : [UInt8] = [0x02, 0xFF, UInt8(lengthLowByte), UInt8(lengthHighByte), ~UInt8(lengthLowByte), ~UInt8(lengthHighByte)]
        print("Telink end Ota Send : \(resultBytes)")
        let writeData = Data.init(bytes: resultBytes, count: 6)
//        AppsBluetoothFacade.directWrite(data: writeData, orderType: .WithOutResponse)
        
        self.writeData(data: writeData)
    }
}
