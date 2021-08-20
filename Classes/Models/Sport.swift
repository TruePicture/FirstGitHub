//
//  Sport.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/3/25.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit

public enum SportType: UInt, Codable {
    case other = 0
    case walk
    case run
    case situp
    case swin
    case ride
    case climbStairs
    case climbMountains
    case stand
    case sit
    case rideIndoor
    case weights            //举重
}

public class Sport: Codable {

    public var index: UInt
    public var type: SportType = .other
    public var time: TimeInterval
    public var step: UInt
    public var calorie: UInt
    public var distance: UInt
    public var duration: UInt
    public var avgBpm: UInt = 0
    
    public init(index: UInt, time: TimeInterval, step: UInt, calorie: UInt, distance: UInt, duration: UInt) {
        self.index = index
        self.time = time
        self.step = step
        self.calorie = calorie
        self.distance = distance
        self.duration = duration
    }
    
    public convenience init(index: UInt, type: SportType, time: TimeInterval, step: UInt, calorie: UInt, distance: UInt, duration: UInt) {
        self.init(index: index, time: time, step: step, calorie: calorie, distance: distance, duration: duration)
        self.type = type
    }
}
