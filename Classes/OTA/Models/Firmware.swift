//
//  Firmware.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/8.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

public enum FirmwareBaseURLPathType:Int, Codable {
    case Doc = 1
    case Cache = 2
    case Tmp = 3
}

public class Firmware: Codable, Equatable {
    
    public var id = 0
    public var name = ""
    
    public var baseURLPathType:FirmwareBaseURLPathType = .Doc
    
    public var baseURLPath:String {
        switch self.baseURLPathType {
            case .Doc:
                let manager = FileManager.default
                let urls = manager.urls(for: .documentDirectory, in: .userDomainMask)
                return urls[0].path
            case .Tmp:
                let tmpDir = NSTemporaryDirectory()
                return tmpDir
            case .Cache:
                let manager = FileManager.default
                let urls = manager.urls(for: .cachesDirectory, in: .userDomainMask)
                return urls[0].path
        }
    }
        
    public var relativeURLPath = ""
    public var path:String {
        if relativeURLPath.count == 0 {
            return ""
        }
        else {
            return baseURLPath.stringByAppending(pathComponent: relativeURLPath)
        }
    }
    
    public var versionName = ""
    public var versionCode = 0.0
    public var type: OtaDataType = .platform
    public var createTime: TimeInterval = Date().timeIntervalSince1970
    
    var description:String {
        return "FW_Path" + self.path
    }
    
    public init() {}
    
    public static func getOtaType(withFileName fileName: String) -> OtaDataType {
        let tmp = fileName.lowercased()
        if tmp.hasPrefix("apollo") {
            return .platform
        }
        else if tmp.hasPrefix("appollo") {
            return .platform
        }
        else if tmp.hasPrefix("appllo") {
            return .platform
        }
        else if tmp.hasPrefix("apollo3") {
            return .platform
        }
        else if tmp.hasPrefix("application") {
            return .platform
        }
        else if tmp.hasPrefix("heartrate") {
            return .heartRate
        }
        else if tmp.hasPrefix("picture") {
            return .picture
        }
        else if tmp.hasPrefix("language") {
            return .picture
        }
        else if tmp.hasPrefix("resmap") {
            return .picture
        }
        else if tmp.hasPrefix("touchpanel") {
            return .touchPanel
        }
        else if tmp.hasPrefix("kl17") {
            return .freeScale
        }
        else if tmp.hasPrefix("mg") {
            return .agps
        }
        else if tmp.hasPrefix("gps") {
            return .gps
        }
        else if tmp.hasPrefix("agps") {
            return .agps
        }
        else {
            return .platform
        }
    }
    
    public static func == (lhs: Firmware, rhs: Firmware) -> Bool {
        return lhs.name == rhs.name
    }
    
    
}
