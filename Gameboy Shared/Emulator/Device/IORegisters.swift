//
//  IORegisters.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 16/7/2568 BE.
//

import Foundation

struct IORegisters {
    var bootSuccess: Bool = false
    var ppu: PPU = PPU()
    var joypadState: JoypadState = JoypadState()
    var interruptsFlag: InterruptRegister = InterruptRegister(value: 0x0)
    var divider: UInt8 = 0x0
    var timerCounter: UInt8 = 0x0
    var timerModulo: UInt8 = 0x0
    var timerControl: TimerControl = .init(value: 0x0)
    var dividerCycleCounter: Int = 0x0
    var timerCycleCounter: Int = 0x0
    
    var serialTransferData: UInt8 = 0x0
    
    struct TimerControl {
        var value: UInt8 {
            didSet {
                tickAtCycle = switch value & 0b00000011 {
                    case 0: 1024
                    case 1: 16
                    case 2: 64
                    case 3: 256
                    default: 0
                }
                
                isEnable = value.bit(2)
            }
        }
        
        /// clock rate in T cycle = M cycle * 4
        var tickAtCycle: Int = 0
        
        var isEnable: Bool = false
    }
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0xFF01:
            serialTransferData = value
        case 0xFF02:
//            print(serialTransferData)
            break
        case 0xFF04:
            divider = 0
        case 0xFF05:
            timerCounter = value
            timerCycleCounter = 0
        case 0xFF06:
            timerModulo = value
        case 0xFF07:
            timerControl.value = value
            timerCycleCounter = 0
        case 0xFF00:
            joypadState.write(value & 0xF0 | joypadState.value & 0x0F)
        case 0xFF0F:
            interruptsFlag.value = value
        case 0xFF40...0xFF4B:
            ppu.write(value, at: address)
        case 0xFF50:
            bootSuccess = value == 1
        default:
            break
        }
    }
    
    func readValue(at address: UInt16) -> UInt8 {
        return switch address {
        case 0xFF00:
            joypadState.read()
        case 0xFF01:
            serialTransferData
//        case 0xFF02:
//            
        case 0xFF04:
            divider
        case 0xFF05:
            timerCounter
        case 0xFF06:
            timerModulo
        case 0xFF07:
            timerControl.value
        case 0xFF40...0xFF4B:
            ppu.readValue(at: address)
        case 0xFF0F:
            interruptsFlag.value
        default:
            0xFF
        }
    }
    
    mutating func advance() {
        dividerCycleCounter &+= 1
        if dividerCycleCounter == 16384 {
            divider &+= 1
            dividerCycleCounter = 0
        }
        
        if timerControl.isEnable {
            timerCycleCounter &+= 1
            if timerCycleCounter >= timerControl.tickAtCycle {
                let result = timerCounter.addingReportingOverflow(1)
                if result.overflow {
                    timerCounter = timerModulo
                    interruptsFlag.set(.timer)
                } else {
                    timerCounter = result.partialValue
                }
                timerCycleCounter = 0
            }
        }
    }
}

extension IORegisters {
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
}
