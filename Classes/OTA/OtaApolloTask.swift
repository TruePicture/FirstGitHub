//
//  OtaApolloTask.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/12/27.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

class OtaApolloTask: OtaTask {
    
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
    
    private func enterUpgradeMode() {
        startOta()
    }
    
    private func otaDeviceDataComes(data: Data) {
    //        print("来数据了：\(data.hexEncodedString())")
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
    
    private func writeDataToNotify(_ data: Data) {
        if checkIsCancel() {
            return
        }
        print("发送（\(UUID.otaNotifyC)）:\(data.hexEncodedString())")
        _ = device.write(data, characteristicUUID: UUID.otaNotifyC)
    }
    
    // MARK: - 写数据
        private func writeData(_ data: Data) {
            if checkIsCancel() {
                return
            }
//            print("\(device.name)，发送（\(UUID.otaWriteC)）:\(data.hexEncodedString())")
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
}
