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
    
    var systemCounter = SystemCounter()
    var divider: UInt8 {
        get { UInt8(systemCounter.value >> 8) & 0xFF }
    }
    
    var timerCounter: UInt8 = 0x0
    var timerModulo: UInt8 = 0x0
    var timerControl: TimerControl = .init(value: 0x0)
    var timerCycleCounter: Int = 0x0
    
    var serialTransferData: UInt8 = 0x0
    
    var isInterruptPending: Bool = false
    
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
        
        var clockModeBit: UInt8 {
            switch value & 0b00000011 {
                case 0: 9
                case 1: 3
                case 2: 5
                case 3: 7
                default: 0
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
            break
        case 0xFF04:
            systemCounter.value = 0
        case 0xFF05:
            timerCounter = value
            timerCycleCounter = 0
        case 0xFF06:
            timerModulo = value
        case 0xFF07:
            timerControl.value = value
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
        if isInterruptPending {
            if timerCycleCounter < 4 {
                timerCycleCounter &+= 1
            } else {
                timerCycleCounter = 0
                interruptsFlag.set(.timer)
                isInterruptPending = false
            }
        }
        let isTick = systemCounter.clock(selectedBit: timerControl.clockModeBit)
        
        if timerControl.isEnable {
            timerCycleCounter &+= 1
            if isTick {
                let result = timerCounter.addingReportingOverflow(1)
                if result.overflow {
                    timerCounter = timerModulo
                    isInterruptPending = true
                } else {
                    timerCounter = result.partialValue
                }
            }
        }
    }
}

struct SystemCounter {
    var value: UInt16 = 0x0
    
    private var _selectedBit: UInt8 = 0x0
    
    mutating func clock(selectedBit index: UInt8) -> Bool {
        if value.bit(index) == true, (value &+ 1).bit(index) == false {
            value &+= 1
            return true
        }
        value &+= 1
        return false
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
