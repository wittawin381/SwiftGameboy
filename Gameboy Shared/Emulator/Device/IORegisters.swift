//
//  IORegisters.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 16/7/2568 BE.
//

import Foundation

struct IORegisters {
    struct JoypadState {
        var value: UInt8 = 0xFF
        
        var dPadSelected: Bool {
            value.bit(4) == false
        }
        
        var buttonSelected: Bool {
            value.bit(5) == false
        }
        
        /// inverse since bit = 0 means key pressed
        var up: Bool = true
        var down: Bool = true
        var left: Bool = true
        var right: Bool = true
        
        var a: Bool = true
        var b: Bool = true
        var start: Bool = true
        var select: Bool = true
        
        mutating func write(_ value: UInt8) {
            self.value = value
        }
        
        func read() -> UInt8 {
            if dPadSelected {
                return down.toUInt8() << 3 | up.toUInt8() << 2 | left.toUInt8() << 1 | right.toUInt8()
            } else if buttonSelected {
                return start.toUInt8() << 3 | select.toUInt8() << 2 | b.toUInt8() << 1 | a.toUInt8()
            }
            return 0xF
        }
    }
    
    var bootSuccess: Bool = false
    var ppu: PPU = PPU()
    var joypadState: JoypadState = JoypadState()
    var interruptsFlag: InterruptRegister = InterruptRegister(value: 0x0)
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0xFF00:
            joypadState.write(value & 0xF0 | joypadState.value & 0x0F)
        case 0xFF40...0xFF4B:
            ppu.write(value, at: address)
        case 0xFF50:
            bootSuccess = value == 1
        case 0xFF0F:
            interruptsFlag.value = value
        default:
            break
        }
    }
    
    func readValue(at address: UInt16) -> UInt8 {
        return switch address {
        case 0xFF00:
            joypadState.read()
        case 0xFF40...0xFF4B:
            ppu.readValue(at: address)
        case 0xFF0F:
            interruptsFlag.value
        default:
            0xFF
        }
    }
}
