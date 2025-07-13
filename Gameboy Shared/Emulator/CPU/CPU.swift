//
//  CPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation
    
struct CPU {
    private var memoryBusDelegate: MemoryBusDelegate
    
    init(memoryBusDelegate: MemoryBusDelegate) {
        self.memoryBusDelegate = memoryBusDelegate
        self.instructionRegister = 0
        self.interruptEnable = 0
        self.stackPointer = 0x0
        self.programCounter = 0x0

        self.registerAF = Register(0x0)
        self.registerBC = Register(0x0)
        self.registerDE = Register(0x0)
        self.registerHL = Register(0x0)
    }
    
    var instructionRegister: UInt8
    var interruptEnable: UInt8
    var stackPointer: UInt16
    var programCounter: UInt16
    
    var registerAF: Register
    var registerBC: Register
    var registerDE: Register
    var registerHL: Register
    
    var carryFlag: Bool {
        registerAF.lo.bit(4)
    }
    
    var zeroFlag: Bool {
        registerAF.lo.bit(7)
    }
    
    mutating func run() {
        let opcode = memory(at: programCounter)
        programCounter += 1
        let instructionBuilder = InstructionBuilder.instructions[opcode]
        if let instructionBuilder {
            let instruction = instructionBuilder.build(&self)
            instruction.perform(&self)
        }
    }
    
    mutating func memory(at address: UInt16) -> UInt8 {
        memoryBusDelegate.readValue(at: address)
    }
    
    mutating func writeValue(_ value: UInt8, toMemoryAt address: UInt16) {
        memoryBusDelegate.write(value, to: address)
    }
    
    mutating func readNextByteAndProceed() -> UInt8 {
        let value = memory(at: programCounter)
        programCounter += 1
        return value
    }
    
    mutating func updateFlagFromAluResult(_ result: ALU.Flag) {
        let flagValue = registerAF.lo
        let flagZero = switch result.zero {
        case let .some(value):
            value.toUInt8()
        case .noneAffected:
            (flagValue >> 7) & 0x1
        }
        
        let flagSubtract = switch result.subtract {
        case let .some(value):
            value.toUInt8()
        case .noneAffected:
            (flagValue >> 6) & 0x1
        }
        
        let flagHalfCarry = switch result.halfCarry {
        case let .some(value):
            value.toUInt8()
        case .noneAffected:
            (flagValue >> 5) & 0x1
        }
        
        let flagCarry = switch result.carry {
        case let .some(value):
            value.toUInt8()
        case .noneAffected:
            (flagValue >> 4) & 0x1
        }
        
        registerAF.lo = createRegisterFValueFromFlag(
            z: flagZero,
            n: flagSubtract,
            h: flagHalfCarry,
            c: flagCarry
        )
    }
    
    struct Register {
        private var _lo: UInt8
        private var _hi: UInt8
        
        init(_ l: UInt8, _ h: UInt8) {
            self._lo = l
            self._hi = h
        }
        
        init(_ value: UInt16) {
            self._lo = UInt8(value & 0xFF)
            self._hi = UInt8(value >> 8)
        }
        
        var lo: UInt8 {
            get { _lo }
            set { _lo = newValue }
        }
        
        var hi: UInt8 {
            get { _hi }
            set { _hi = newValue }
        }
        
        var all: UInt16 {
            get { (UInt16(_hi) << 8) + UInt16(_lo) }
            set {
                _hi = UInt8(newValue >> 8)
                _lo = UInt8(newValue);
            }
        }
    }
}
