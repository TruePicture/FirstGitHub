//
//  DataExtensions.swift
//  BLE-Swift
//
//  Created by SuJiang on 2018/10/15.
//  Copyright © 2018 ss. All rights reserved.
//

import Foundation

public struct HexEncodingOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue:Int) {
        self.rawValue = rawValue
    }
    static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
}

// MARK: - Properties
public extension Data {
    
    /// SwifterSwift: Return data as an array of bytes.
    var bytes: [UInt8] {
        // http://stackoverflow.com/questions/38097710/swift-3-changes-for-getbytes-method
        return [UInt8](self)
    }
    
    func subdata(in range: CountableClosedRange<Data.Index>) -> Data
    {
        return self.subdata(in: range.lowerBound..<range.upperBound + 1)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
    mutating func append(bytes: UnsafeRawPointer, count: Int) {
        let data = Data(bytes: bytes, count: count)
        append(data)
    }
}
