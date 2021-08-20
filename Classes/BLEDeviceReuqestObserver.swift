//
//  BLEDeviceReuqestObserver.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/12/12.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

//protocol BLEDeviceReuqestObserverDelegate : NSObjectProtocol {
//    func didReceiveDeviceRequest(data:Data, type:Data)
//}

open class BLEDeviceReuqestObserver: NSObject {

//    private static var maps = Dictionary<Data, Array<BLEDeviceReuqestObserverDelegate>>()
    
//    public static let shared = BLEDeviceReuqestObserver()
//    public var delegate:BLEDeviceReuqestObserverDelegate? = nil

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveCMD(note:)), name: BLEInnerNotification.deviceDataUpdate, object: nil)
    }
    
//    public func registerResponder(responder:BLEDeviceReuqestObserverDelegate!, for cmd:Data) {
//
//        var responders:Array<BLEDeviceReuqestObserverDelegate>? = BLEDeviceReuqestObserver.maps[cmd] ?? nil
//        if (responders == nil) {
//            responders = Array<BLEDeviceReuqestObserverDelegate>()
//        }
//
//        if (responders?.contains(where: { (item:BLEDeviceReuqestObserverDelegate) -> Bool in
//            return !item.isEqual(responder)
//        }))! {
//            responders!.append(responder)
//        }
//    }
//
//    public func removeResponder(responder:BLEDeviceReuqestObserverDelegate!, for cmd:Data) {
//        let responders:Array<BLEDeviceReuqestObserverDelegate>? = BLEDeviceReuqestObserver.maps[cmd] ?? nil
//
//        if (responders == nil) {
//            return
//        }
//
//        let resultResponders = responders?.filter({ (item:BLEDeviceReuqestObserverDelegate) -> Bool in
//            return !item.isEqual(responder)
//        })
//        BLEDeviceReuqestObserver.maps[cmd] = resultResponders
//    }
    
    var receivedData : Data? = nil
    var receivedDataLength : Int = 0;
    var type : Data? = nil
    //07d40e00790000590a00
    @objc open func receiveCMD(note:Notification!) {
        let characterID:String = note.userInfo?[BLEKey.uuid] as! String
        let data:Data = note.userInfo?[BLEKey.data] as! Data
        let device: BLEDevice = note.userInfo?[BLEKey.device] as! BLEDevice
        
        print("recv data iiiiiiiiiii:\(data.hexEncodedString())")
        print("recv data length is :\(data.count)")
        
        if characterID == UUID.c2A37 {
            
            // 强制转为 E2
            let E2Bytes:[UInt8]  =  [0xE2];
            let E2Data:Data = Data(bytes: E2Bytes, count: E2Bytes.count);
            
            self .didReceiveDeviceRequest(device:device, data: data[1...1], cmd: E2Data, type: data)
            return
        }
        
        
        if characterID == UUID.tlsrOtaUuid {
            self.didReceiveDeviceRequest(device:device, data: data, cmd: data, type: data)
            return
        }
        
        let mBytes:[UInt8]  =  [0x02];
        let cmdData:Data = Data(bytes: mBytes, count: mBytes.count);
        type = data[1...1]
        if characterID == UUID.algorithmCollectionConfigureChannel || characterID == UUID.algorithmCollectionDataChannel1 || characterID == UUID.algorithmCollectionDataChannel2{
            
            if data.count > 18 {
                self .didReceiveDeviceRequest(device:device, data: data, cmd: cmdData, type: type!)
            }else{
                if data[0] == 0x7f && data.count >= 5 {
                    receivedData = data
                    receivedDataLength = data[3...4].int + 6
                    type = data[2...2]
                }
                else {
//                    receivedData = receivedData! + data
                    if self.receivedData != nil {
                        self.receivedData = self.receivedData! + data
                    }
                }
                
                // 接收数据总长度正确，并且接收的数据也真的是到尾部了
                if receivedData?.count == receivedDataLength && receivedDataLength > 6 && (data.last == 0x9f) {
                    let result = receivedData![5...(receivedDataLength - 1 - 1)];
                    self .didReceiveDeviceRequest(device:device, data: result, cmd: data[1...1], type: type!)
                    
                    type = nil
                    receivedData = nil
                    receivedDataLength = 0
                }
            }
            return
        }
        
        if data.count > 6 && data[0] == 0x6f && data[5] == 0xD5 && data[6] == 0 {
            return
        }
        
        // 进行数据处理
        if data[0] == 0x6f && data.count >= 5 {
            receivedData = data
            receivedDataLength = data[3...4].int + 6
            type = data[2...2]
        }
        else {
            if self.receivedData != nil {
                self.receivedData = self.receivedData! + data
            } else {
                return;
            }
        }
        
        // 接收数据总长度正确，并且接收的数据也真的是到尾部了 6fe2710100 4c 8f
        if receivedData?.count == receivedDataLength && receivedDataLength > 6 && (data.last == 0x8f) {
            let result = receivedData![5...(receivedDataLength - 1 - 1)];
//            BLEDeviceReuqestObserver.maps[data[1...1]]?.forEach({ (item:BLEDeviceReuqestObserverDelegate?) in
//                item?.didReceiveDeviceRequest(data: result, type: type!)
//            })
//
//            delegate?.didReceiveDeviceRequest(data: result, type: type!)
            
            self.didReceiveDeviceRequest(device:device, data: result, cmd: data[1...1], type: type!)
            
            type = nil
            receivedData = nil
            receivedDataLength = 0
        }
        
    }
    
    // For override
//    open func didReceiveDeviceRequest(data:Data, cmd:Data, type:Data) {
//
//    }
    
    // For override
    open func didReceiveDeviceRequest(device: BLEDevice, data:Data, cmd:Data, type:Data) {

    }
}
