//
//  ALU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 3/7/2568 BE.
//

import Foundation

public enum ALU {
    public struct Flag {
        public enum Value {
            case some(Bool)
            case noneAffected
        }
        
        public let zero: Value
        public let subtract: Value
        public let halfCarry: Value
        public let carry: Value
        
        public init(zero: Value, subtract: Value, halfCarry: Value, carry: Value) {
            self.zero = zero
            self.subtract = subtract
            self.halfCarry = halfCarry
            self.carry = carry
        }
    }
    
    public struct Result<Value> {
        let value: Value
        let flag: Flag
        
        enum FlagValue {
            case some(Bool)
            case noneAffected
        }
    }
    
    static func add(_ x: UInt8, _ y: UInt8, carry: Bool = false) -> Result<UInt8> {
        let carryValue = carry.toUInt8()
        let result = x &+ y &+ carryValue
        let zeroFlag = result == 0
        let subtractFlag = false
        let halfCarryFlag = (x & 0xF) &+ (y & 0xF) &+ carryValue > 0xF
        let carryFlag = UInt16(x) &+ UInt16(y) &+ carry.toUInt16() > 0xFF
        return Result(
            value: result,
            flag: Flag(
                zero: .some(zeroFlag),
                subtract: .some(subtractFlag),
                halfCarry: .some(halfCarryFlag),
                carry: .some(carryFlag)
            )
        )
    }
    
    static func add16(_ x: UInt16, _ y: UInt16) -> Result<UInt16> {
        let result = x &+ y
        let halfCarryFlag = (x & 0xFFF) &+ (y & 0xFFF) > 0xFFF
        let carryFlag = UInt32(x) &+ UInt32(y) > 0xFFFF
        return Result(
            value: result,
            flag: Flag(
                zero: .noneAffected,
                subtract: .some(false),
                halfCarry: .some(halfCarryFlag),
                carry: .some(carryFlag)
            )
        )
    }
    
    static func increment(_ value: UInt8) -> Result<UInt8> {
        let result = value &+ 1
        return Result(
            value: result,
            flag: Flag(
                zero: .some(result == 0),
                subtract: .some(false),
                halfCarry: .some((value & 0x0F) &+ 1 > 0x0F),
                carry: .noneAffected
            )
        )
    }
    
    static func decrement(_ value: UInt8) -> Result<UInt8> {
        let result = value &- 1
        return Result(
            value: result,
            flag: Flag(
                zero: .some(result == 0),
                subtract: .some(true),
                halfCarry: .some(result < 0x1),
                carry: .noneAffected
            )
        )
    }
    
    static func sub(_ x: UInt8, _ y: UInt8, carry: Bool = false) -> Result<UInt8> {
        let result = x &- y &- carry.toUInt8()
        let zeroFlag = result == 0
        let subtractFlag = true
        let halfCarryFlag = (x & 0xF) &- (y & 0xF) &- carry.toUInt8() < 0xF
        let carryFlag = UInt16(x) &- UInt16(y) &- carry.toUInt16() < 0xFF
        return Result(
            value: result,
            flag: Flag(
                zero: .some(zeroFlag),
                subtract: .some(subtractFlag),
                halfCarry: .some(halfCarryFlag),
                carry: .some(carryFlag)
            )
        )
    }
    
    static func and(_ x: UInt8, _ y: UInt8) -> Result<UInt8> {
        let result = x & y
        return Result(
            value: result,
            flag: Flag(
                zero: .some(result == 0),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
    }
    
    static func or(_ x: UInt8, _ y: UInt8) -> Result<UInt8> {
        let result = x | y
        return Result(
            value: result,
            flag: Flag(
                zero: .some(result == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
    }
    
    static func xor(_ x: UInt8, _ y: UInt8) -> Result<UInt8> {
        let result = x ^ y
        return Result(
            value: result,
            flag: Flag(
                zero: .some(result == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
    }
}
