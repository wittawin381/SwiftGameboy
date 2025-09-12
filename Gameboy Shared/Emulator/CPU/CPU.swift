//
//  CPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation

var enableDebug: Bool = false

public struct CPU {
    public init() {
        self.instructionRegister = 0
        self.interruptMasterEnabled = false
        self.stackPointer = 0x0
        self.programCounter = 0x0

        self.registerAF = Register(0x0)
        self.registerBC = Register(0x0)
        self.registerDE = Register(0x0)
        self.registerHL = Register(0x0)
    }
        
    public var instructionRegister: UInt8
    public var stackPointer: UInt16
    public var programCounter: UInt16
        
    public var registerAF: Register
    public var registerBC: Register
    public var registerDE: Register
    public var registerHL: Register 
    public var interruptMasterEnabled: Bool = false
    public var interruptEnable: InterruptRegister = .init(value: 0x0)
    public var isInterruptMasterEnabledRequest: Bool = false
    public var isHalted: Bool = false
        
    public var carryFlag: Bool {
        registerAF.lo.bit(4)
    }
    
    public var zeroFlag: Bool {
        registerAF.lo.bit(7)
    }
    
    public var cycleCounter: Int = 0
        
    public mutating func updateFlag(_ flag: ALU.Flag) {
        let zero = switch flag.zero {
        case let .some(value):
            value.toUInt8() << 7
        case .noneAffected:
            registerAF.lo & 0b1000_0000
        }
        
        let subtract = switch flag.subtract {
        case let .some(value):
            value.toUInt8() << 6
        case .noneAffected:
            registerAF.lo & 0b0100_0000
        }
        
        let halfCarry = switch flag.halfCarry {
        case let .some(value):
            value.toUInt8() << 5
        case .noneAffected:
            registerAF.lo & 0b0010_0000
        }
        
        let carry = switch flag.carry {
        case let .some(value):
            value.toUInt8() << 4
        case .noneAffected:
            registerAF.lo & 0b0001_0000
        }
        
        registerAF.lo = zero | subtract | halfCarry | carry
    }
    
    mutating func setRegister(_ registerIndex: UInt8, value: UInt8) {
        switch registerIndex {
        case 0:
            registerBC.hi = value
        case 1:
            registerBC.lo = value
        case 2:
            registerDE.hi = value
        case 3:
            registerDE.lo = value
        case 4:
            registerHL.hi = value
        case 5:
            registerHL.lo = value
        case 7:
            registerAF.hi = value
        default:
            fatalError("index out of range")
        }
    }
    
    func getRegister(_ registerIndex: UInt8) -> UInt8 {
        return switch registerIndex {
        case 0:
            registerBC.hi
        case 1:
            registerBC.lo
        case 2:
            registerDE.hi
        case 3:
            registerDE.lo
        case 4:
            registerHL.hi
        case 5:
            registerHL.lo
        case 7:
            registerAF.hi
        default:
            fatalError("index out of range")
        }
    }
    
    mutating func setPairedRegisterWithSP(_ registerIndex: UInt8, value: UInt16) {
        switch registerIndex {
        case 0:
            registerBC.all = value
        case 1:
            registerDE.all = value
        case 2:
            registerHL.all = value
        case 3:
            stackPointer = value
        default:
            fatalError("index out of range")
        }
    }
    
    func getPairedRegisterWithSP(_ registerIndex: UInt8) -> UInt16 {
        return switch registerIndex {
        case 0:
            registerBC.all
        case 1:
            registerDE.all
        case 2:
            registerHL.all
        case 3:
            stackPointer
        default:
            fatalError("index out of range")
        }
    }
    
    mutating func setPairedRegisterWithAF(_ registerIndex: UInt8, value: UInt16) {
        switch registerIndex {
        case 0:
            registerBC.all = value
        case 1:
            registerDE.all = value
        case 2:
            registerHL.all = value
        case 3:
            registerAF.all = value & 0xFFF0
        default:
            fatalError("index out of range")
        }
    }
    
    func getPairedRegisterWithAF(_ registerIndex: UInt8) -> UInt16 {
        return switch registerIndex {
        case 0:
            registerBC.all
        case 1:
            registerDE.all
        case 2:
            registerHL.all
        case 3:
            registerAF.all
        default:
            fatalError("index out of range")
        }
    }
}
