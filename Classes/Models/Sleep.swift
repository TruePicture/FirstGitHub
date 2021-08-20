//
//  Sleep.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/25.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

public enum SleepMode:UInt8 {
    case deep = 0x00
    case shallow = 0x01
    case wake = 0x02
    case prepare = 0x03
    case rem = 0x05
    case enter = 0x10
    case exit = 0x11
    case exit2 = 0x12
}

public protocol PropertyHelper
{
    func allProperties() throws -> [String: Any]
    func getMemberIntValue<T>(tuple: T) -> Int
    static func pointerRedirectToParse<T>(origin: T?) -> Any
}

public extension PropertyHelper
{
    func allProperties() throws -> [String: Any] {

        var result: [String: Any] = [:]

        let mirror = Mirror(reflecting: self)

        guard let style = mirror.displayStyle , style == .struct || style == .class else {
            //throw some error
            throw NSError(domain: "hris.to", code: 777, userInfo: nil)
        }

        for (labelMaybe, valueMaybe) in mirror.children {
            guard let label = labelMaybe else {
                continue
            }

            result[label] = valueMaybe
        }

        return result
    }
    
    func getMemberIntValue<T>(tuple: T) -> Int {
        let mirror = Mirror(reflecting: tuple)
        var data = Data.init()
        for (_, value) in mirror.children {

            if value is UInt8 {
                data.append(value as! UInt8)
            }
        }
        return data.int
    }
    
    static func pointerRedirectToParse<T>(origin: T?) -> Any {
        
        var originData = origin
        
        if originData is Array<Data> {
            var result:Array<Self>! = []
            
            for data in originData as! Array<Data> {
                var tmpData = data
                let pointer = UnsafeMutablePointer(&tmpData)
                var sleep:Self? = nil
                let _ = pointer.withMemoryRebound(to: Self.self, capacity: 1) { (ptr) in
                    sleep = ptr.pointee
                }
                
                if sleep != nil {
                    result.append(sleep!)
                }
            }
            
            if result.count > 0 {
                return result as Any
            }
            else {
                result = nil
                return result as Any
            }
            
//            let pointer = UnsafeMutablePointer(&originData)
//            let _ = pointer.withMemoryRebound(to: Array<Self>.self, capacity: (originData as! Array<Data>).count) { (ptr) in
//                result = ptr.pointee
//            }
//
//            return result as Any
        }
        else {
            var result:Self? = nil
            let pointer = UnsafeMutablePointer(&originData)
            let _ = pointer.withMemoryRebound(to: Self.self, capacity: 1) { (ptr) in
                result = ptr.pointee
            }
            
            return result as Any
        }
    }
    
}

public struct Sleep:PropertyHelper {
    private var member_index:(UInt8, UInt8) = (0, 0)
    private var member_time:(UInt8, UInt8, UInt8, UInt8) = (0, 0, 0, 0)
    private var member_type:UInt8 = 0
    private var member_reserve1:UInt8 = 0
    private var member_reserve2:(UInt8, UInt8) = (0, 0)
    
    public var index:Int {
        get {
            return self.getMemberIntValue(tuple: member_index)
        }
    }
    
    public var time:Int {
        get {
            return self.getMemberIntValue(tuple: member_time)
        }
    }
    
    public var type:SleepMode {
        get {
            return SleepMode(rawValue: member_type)!
        }
    }
}
