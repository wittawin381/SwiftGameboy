//
//  CPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation
    
struct CPU {
    init() {
        self.instructionRegister = 0
        self.interruptMasterEnabled = false
        self.stackPointer = 0x0
        self.programCounter = 0x0

        self.registerAF = Register(0x0)
        self.registerBC = Register(0x0)
        self.registerDE = Register(0x0)
        self.registerHL = Register(0x0)
    }
    
    var instructionRegister: UInt8
    var stackPointer: UInt16
//    {
//        willSet {
//            print("\(stackPointer) new: \(newValue)")
//        }
//    }
    var programCounter: UInt16
    
    var registerAF: Register
    var registerBC: Register
    var registerDE: Register
    var registerHL: Register
    
    var interruptMasterEnabled: Bool = false
    var interruptEnable: InterruptRegister = .init(value: 0x0)
    
    var carryFlag: Bool {
        registerAF.lo.bit(4)
    }
    
    var zeroFlag: Bool {
        registerAF.lo.bit(7)
    }
    
    mutating func update(readMemory: (UInt16) -> UInt8, writeMemory: (UInt8, UInt16) -> Void) {
        let opcode = readMemory(programCounter)
        print(String(format: "%llx %llx", opcode, programCounter))
        programCounter += 1
        let instructionBuilder = InstructionBuilder.instructions[opcode]
        if let instructionBuilder {
            let instruction = instructionBuilder.build(&self, readMemory, writeMemory)
            instruction.perform(&self, readMemory, writeMemory)
        }
    }
    
    mutating func handleInterrupt(readMemory: (UInt16) -> UInt8, writeMemory: (UInt8, UInt16) -> Void) {
        var interruptFlag = InterruptRegister(value: readMemory(0xFF0F))
        guard interruptMasterEnabled else { return }
        
        if let respondedInterrupt = interruptFlag.findFirstRespondedInterrupt(using: interruptEnable){
            stackPointer -= 1
            writeMemory(UInt8(programCounter >> 8), stackPointer)
            stackPointer -= 1
            writeMemory(UInt8(programCounter & 0xFF), stackPointer)
            programCounter = respondedInterrupt.address
            
            interruptFlag.unset(respondedInterrupt)
            writeMemory(interruptFlag.value, 0xFF0F)
        }
    }
    
    mutating func updateFlag(_ flag: ALU.Flag) {
        let flagValue = registerAF.lo
        let flagZero = switch flag.zero {
        case let .some(value):
            value.toUInt8()
        case .noneAffected:
            (flagValue >> 7) & 0x1
        }
        
        let flagSubtract = switch flag.subtract {
        case let .some(value):
            value.toUInt8()
        case .noneAffected:
            (flagValue >> 6) & 0x1
        }
        
        let flagHalfCarry = switch flag.halfCarry {
        case let .some(value):
            value.toUInt8()
        case .noneAffected:
            (flagValue >> 5) & 0x1
        }
        
        let flagCarry = switch flag.carry {
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
}
