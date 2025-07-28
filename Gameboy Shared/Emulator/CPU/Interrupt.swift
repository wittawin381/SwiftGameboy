//
//  Interrupt.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 28/7/2568 BE.
//

import Foundation

struct InterruptRegister {
    var value: UInt8
    
    enum Interrupt {
        case vBlank
        case lcd
        case timer
        case serial
        case joypad
        
        var address: UInt16 {
            return switch self {
            case .vBlank    : 0x40
            case .lcd       : 0x48
            case .timer     : 0x50
            case .serial    : 0x58
            case .joypad    : 0x60
            }
        }
    }
    
    func findFirstRespondedInterrupt(using interruptEnable: InterruptRegister) -> Interrupt? {
        if vBlank && interruptEnable.vBlank { return .vBlank }
        if lcd && interruptEnable.lcd { return .lcd }
        if timer && interruptEnable.timer { return .timer }
        if serial && interruptEnable.serial { return .serial }
        if joypad && interruptEnable.joypad { return .joypad }
        return nil
    }
    
    mutating func set(_ interrupt: Interrupt) {
        switch interrupt {
        case .vBlank:
            vBlank = true
        case .lcd:
            lcd = true
        case .timer:
            timer = true
        case .serial:
            serial = true
        case .joypad:
            joypad = true
        }
    }
    
    mutating func unset(_ interrupt: Interrupt) {
        switch interrupt {
        case .vBlank:
            vBlank = false
        case .lcd:
            lcd = false
        case .timer:
            timer = false
        case .serial:
            serial = false
        case .joypad:
            joypad = false
        }
    }
    
    private var vBlank: Bool {
        get { value.bit(0) }
        set { updateBit(at: 0, value: newValue) }
    }
    
    private var lcd: Bool {
        get { value.bit(1) }
        set { updateBit(at: 1, value: newValue) }
    }
    
    private var timer: Bool {
        get { value.bit(2) }
        set { updateBit(at: 2, value: newValue) }
    }
    
    private var serial: Bool {
        get { value.bit(3) }
        set { updateBit(at: 3, value: newValue) }
    }
    
    private var joypad: Bool {
        get { value.bit(4) }
        set { updateBit(at: 4, value: newValue) }
    }
    
    private mutating func updateBit(at index: UInt8, value: Bool) {
        self.value.setBit(at: index, to: value.toUInt8())
    }
}
