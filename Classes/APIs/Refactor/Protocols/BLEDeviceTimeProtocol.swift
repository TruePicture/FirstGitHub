//
//  BLEDeviceTimeProtocol.swift
//  BluetoothSDK-swift
//
//  Created by guotonglin on 2020/9/23.
//

import Foundation

public protocol BLEDeviceTimeProtocol {
    func synDate(boolCallback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask?
}

public extension BLEDeviceTimeProtocol {
    
    func synDate(boolCallback:BoolCallback?, toDeviceName deviceName:String?) -> BLETask? {

        let nowDate = NSDate()
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: Locale.preferredLanguages.first!)
        dateFormat.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let strTime = dateFormat.string(from: nowDate as Date)
        let arrayDate = strTime.components(separatedBy: "-")
        
        var year = arrayDate[0]
        let month = UInt8(Int(arrayDate[1])!)
        let day = UInt8(Int(arrayDate[2])!)
        let hour = UInt8(Int(arrayDate[3])!)
        let min = UInt8(Int(arrayDate[4])!)
        let sec = UInt8(Int(arrayDate[5])!)
        
        
//        let dateYear = NSData(bytes: &year, length: 4)
//
//        let byteYear = [UInt8](dateYear)
//
//
        let totalLengthData = Data(bytes: &year, count: 2)
        let yearBytes   = [UInt8](totalLengthData)
        
        var yearByte1 : UInt8 = 0
        var yearByte2 : UInt8 = 0
        
        if yearBytes.count > 0 {
            yearByte1 = yearBytes[0]
        }
        if yearBytes.count > 1 {
            yearByte2 = yearBytes[1]
        }
        
        
        
        let timeZone = TimeZone.current
        var timeZoneSecond = timeZone.secondsFromGMT()
        
        var state: UInt8 = 0
        if timeZoneSecond > 0 {
            state = 1;
        } else {
            timeZoneSecond *= -1;
        }
        
        let hourTimeZoneTemp: UInt8 = UInt8(timeZoneSecond / 3600)
        let hourTemp: UInt8 = UInt8(timeZoneSecond % 3600)
        let minTimeZoneTemp: UInt8 = hourTemp / 60
        

        let bytes : [UInt8] = [0x6F,0x04,0x71,0x0C,0x00,
                              0xE4,0x07, month,day,hour,min,sec, 0x01,0x00,state,hourTimeZoneTemp,minTimeZoneTemp,0x8f]
        let data2 = Data.init(bytes: bytes, count: bytes.count)
        
        return BLECenter.shared.send(data: data2, boolCallback: boolCallback, toDeviceName: deviceName)

        //        Byte cmd[] = {0x6f, 0x04,0x71, 0x0C,0x00,byteYear[0],byteYear[1],month,day,hour,min,sec,!is24H,type,state,hourTimeZoneTemp,minTimeZoneTemp, 0x8f};
    }
    
}
