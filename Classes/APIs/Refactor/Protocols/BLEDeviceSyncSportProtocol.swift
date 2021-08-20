//
//  BLEDeviceSyncSportProtocol.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2020/4/1.
//  Copyright © 2020 ss. All rights reserved.
//

import Foundation
public protocol BLEDeviceSyncSportProtocol {
    func getSportDetail(num: UInt16, callback:((Array<Sport>?, BLEError?)->Void)?, toDeviceName deviceName:String?) -> BLETask?
}

public extension BLEDeviceSyncSportProtocol {
    
    func getSportDetail(num: UInt16, callback:((Array<Sport>?, BLEError?)->Void)?, toDeviceName deviceName:String? = nil)->BLETask? {
        if num == 0 {
            callback?(nil, BLEError.taskError(reason: .paramsError))
            return nil
        }
        
        let data = Data([0x6f,0x54,0x70,0x02,0x00,0x00,0x00,0x8f])
        return BLECenter.shared.send(data: data, recvCount: Int(num), dataArrayCallback: { (datas, err) in
            if let error = err {
                callback?(nil, error)
            } else {
                guard let ds = datas, ds.count > 0, ds[0].count >= 22 else {
                    print("send.datas is \(data.hexEncodedString())")
                    print("ds.datas is \(datas)")
                    print("ds.count is \(datas?.count)")
                    print("ds.count is \(datas?[0].count)")
                    print("ds.count【0】 is \(datas?[0].hexEncodedString())")
                    print("error llllllllll .dataError")
                    callback?(nil, BLEError.taskError(reason: .dataError))
                    return
                }
                
                var sports = Array<Sport>()
                for d in ds {
                    if d.count < 22 {
                        print("222222 ds.count is \(ds.count)")
                        print("error llllllllll 2222  .dataError")
                        callback?(nil, BLEError.taskError(reason: .dataError))
                        return
                    }
                    let bytes = d.bytes
                    
                    let index = d[0...1].uint
                    let time = d[2...5].uint
                    let step = d[6...9].uint
                    let cal = d[10...13].uint
                    let dis = d[14...17].uint
                    let du = d[18...21].uint
                    
                    let sport = Sport(index: index, time: TimeInterval(time), step: step, calorie: cal, distance: dis, duration: du)
                    
                    if d.count >= 24 {
                        let avgHr = UInt(bytes[22])
                        let type = SportType(rawValue: UInt(bytes[23]))
                        sport.avgBpm = avgHr
                        sport.type = type!
                    }
                    
                    sports.append(sport)
                }
            
                callback?(sports, nil)
            }
        }, toDeviceName: deviceName)
    }
    
}
