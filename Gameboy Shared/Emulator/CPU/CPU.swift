//
//  CPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation
    
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
    
    public var pendingInstruction: Instruction?
    
    var tickCountEnabled: Bool = false
    var tickCount: Int = 0
    
    mutating func advance(readMemory: (UInt16) -> UInt8, writeMemory: (UInt8, UInt16) -> Void) {
        cycleCounter += 1
        if let pendingInstruction{
            if cycleCounter > (pendingInstruction.cycles * 4) - 1 {
                pendingInstruction.perform(&self, readMemory, writeMemory)
                cycleCounter = 0
                self.pendingInstruction = nil
            }
            return
        } else {
            if isInterruptMasterEnabledRequest {
                interruptMasterEnabled = true
                isInterruptMasterEnabledRequest = false
            }
            
            handleInterrupt(readMemory: readMemory, writeMemory: writeMemory)
            
            if !isHalted {
                
                let opcode = readMemory(programCounter)
                
    //                    let printOpcode = if opcode == 0xCB {
    //                        readMemory(programCounter + 1)
    //                    } else {
    //                        opcode
    //                    }
                
                programCounter &+= 1
                let instructionBuilder = InstructionBuilder.instructions[opcode]
                if let instructionBuilder {
                    let instruction = instructionBuilder.build(&self, readMemory, writeMemory)
                    cycleCounter = 1
                    pendingInstruction = instruction
                }
            }
        }
    }
    
    public mutating func handleInterrupt(readMemory: (UInt16) -> UInt8, writeMemory: (UInt8, UInt16) -> Void) {
        var interruptFlag = InterruptRegister(value: readMemory(0xFF0F))
        
        if interruptEnable.value & interruptFlag.value != 0 {
            isHalted = false
        }

        guard interruptMasterEnabled else { return }
                
        if let respondedInterrupt = interruptFlag.findFirstRespondedInterrupt(using: interruptEnable){
            stackPointer -= 1
            writeMemory(UInt8(programCounter >> 8), stackPointer)
            stackPointer -= 1
            writeMemory(UInt8(programCounter & 0xFF), stackPointer)
            programCounter = respondedInterrupt.address
            
            interruptFlag.unset(respondedInterrupt)
            interruptMasterEnabled = false
            writeMemory(interruptFlag.value, 0xFF0F)
        }
    }
    
    public mutating func updateFlag(_ flag: ALU.Flag) {
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
