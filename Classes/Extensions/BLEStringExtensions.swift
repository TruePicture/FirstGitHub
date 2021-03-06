//
//  StringExtensions.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/7.
//  Copyright © 2019 ss. All rights reserved.
//

import Foundation
public extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: self.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    static func dateString(withFormat format: String, timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: date)
    }
    
    static func timeString(fromTimeInterval timeInterval: TimeInterval) -> String {
        return dateString(withFormat: "yyyy-MM-dd HH:mm:ss", timeInterval: timeInterval)
    }
}
