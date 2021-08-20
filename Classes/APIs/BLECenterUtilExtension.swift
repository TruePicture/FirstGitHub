//
//  BLECenterUtilExtension.swift
//  BLE-Swift
//
//  Created by Kevin Chen on 2019/11/29.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation

class BLECenterUtilExtension: BLECenter {
//    public func dataToInt32(data :Data) -> Int32 {
//
//        let result: Int32 = 0;
//
//        data.getbyte
//
//        return 0
//    }
}

extension Data {
    
    public var uint8: UInt8 {
        get {
            let value = UInt8(littleEndian: self.withUnsafeBytes { $0.pointee })
            return value;
        }
    }
    
    public var uint16: UInt16 {
        get {
            let value = UInt16(littleEndian: self.withUnsafeBytes { $0.pointee })
            return value;
        }
    }
    
    var uint32: UInt32 {
        get {
            let value = UInt32(littleEndian: self.withUnsafeBytes { $0.pointee })
            return value;
        }
    }
    
    var uint64: UInt64 {
        get {
            let value = UInt64(littleEndian: self.withUnsafeBytes { $0.pointee })
            return value;
        }
    }
    
    var uint: UInt {
        get {
            
            let dataCount = self.count
            
            if dataCount <= 1 {
                return UInt(self.uint8)
            }
            else if dataCount > 1 && dataCount <= 2 {
                return UInt(self.uint16)
            }
            else if dataCount > 2 && dataCount <= 4 {
                return UInt(self.uint32)
            }
            else if dataCount > 4 && dataCount <= 8 {
                return UInt(self.uint64)
            }
            else {
                return 0
            }
        }
    }
    
    var int8: Int8 {
        get {
            let value = Int8(littleEndian: self.withUnsafeBytes { $0.pointee })
            return value;
        }
    }
    
    var int16: Int16 {
        get {
            let value = Int16(littleEndian: self.withUnsafeBytes { $0.pointee })
            return value;
        }
    }
    
    var int32: Int32 {
        get {
            let value = Int32(littleEndian: self.withUnsafeBytes { $0.pointee })
            return value;
        }
    }
    
    var int64: Int64 {
        get {
            let value = Int64(littleEndian: self.withUnsafeBytes { $0.pointee })
            return value;
        }
    }
    
    var int: Int {
        get {
            let dataCount = self.count
            
            if dataCount <= 1 {
                return Int(self.int8)
            }
            else if dataCount > 1 && dataCount <= 2 {
                return Int(self.int16)
            }
            else if dataCount > 2 && dataCount <= 4 {
                return Int(self.int32)
            }
            else if dataCount > 4 && dataCount <= 8 {
                return Int(self.int64)
            }
            else {
                return 0
            }
        }
    }
    
//    var uuid: NSUUID? {
//        get {
//            var bytes = [UInt8](repeating: 0, count: self.count)
//            self.copyBytes(to:&bytes, count: self.count * MemoryLayout<UInt32>.size)
//            return NSUUID(uuidBytes: bytes)
//        }
//    }
//    var stringASCII: String? {
//        get {
//            return NSString(data: self, encoding: String.Encoding.ascii.rawValue) as String?
//        }
//    }
//    
//    var stringUTF8: String? {
//        get {
//            return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as String?
//        }
//    }
//
//    struct HexEncodingOptions: OptionSet {
//        let rawValue: Int
//        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
//    }
    
//    func hexEncodedString(options: HexEncodingOptions = []) -> String {
//        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
//        return map { String(format: format, $0) }.joined()
//    }
    
}

extension Int {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int>.size)
    }
    
    func data(byteCount:Int) -> Data {
        var int = self
        return Data(bytes: &int, count: byteCount)
    }
}

extension UInt8 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt8>.size)
    }
    
    func data(byteCount:Int) -> Data {
        var int = self
        return Data(bytes: &int, count: byteCount)
    }
}

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
    
    func data(byteCount:Int) -> Data {
        var int = self
        return Data(bytes: &int, count: byteCount)
    }
}

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }
    
    func data(byteCount:Int) -> Data {
        var int = self
        return Data(bytes: &int, count: byteCount)
    }
//    var byteArrayLittleEndian: [UInt8] {
//        return [
//            UInt8((self & 0xFF000000) >> 24),
//            UInt8((self & 0x00FF0000) >> 16),
//            UInt8((self & 0x0000FF00) >> 8),
//            UInt8(self & 0x000000FF)
//        ]
//    }
}

extension UInt64 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt64>.size)
    }
    
    func data(byteCount:Int) -> Data {
        var int = self
        return Data(bytes: &int, count: byteCount)
    }
}
