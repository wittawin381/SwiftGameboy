//
//  CPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation

public struct CPU: ~Copyable {
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
        
    var pendingInstruction: InstructionV4?
    
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
}

extension CPU {
    static func run(on gb: inout GB) {
        gb.cpu.cycleCounter += 1
        if let pendingInstruction = gb.cpu.pendingInstruction {
            if gb.cpu.cycleCounter > (pendingInstruction.cycles * 4) - 1 {
                gb.cpu.pendingInstruction?.perform(&gb)
                gb.cpu.cycleCounter = 0
                gb.cpu.pendingInstruction = nil
            }
            return
        } else {
            if gb.cpu.isInterruptMasterEnabledRequest {
                gb.cpu.interruptMasterEnabled = true
                gb.cpu.isInterruptMasterEnabledRequest = false
            }

            handleInterrupt(gb: &gb)

            if !gb.cpu.isHalted {

                let opcode = gb.read(gb.cpu.programCounter)
                gb.cpu.programCounter &+= 1
                let instructionBuilder = InstructionBuilderV4.instructions[opcode]
                if let instructionBuilder {
                    let instruction = instructionBuilder.build(&gb)
                    gb.cpu.cycleCounter = 1
                    gb.cpu.pendingInstruction = instruction
                }
            }
        }
    }
    
    private static func handleInterrupt(gb: inout GB) {
        var interruptFlag = InterruptRegister(value: gb.read(0xFF0F))
        
        if gb.cpu.interruptEnable.value & interruptFlag.value != 0 {
            gb.cpu.isHalted = false
        }

        guard gb.cpu.interruptMasterEnabled else { return }
                
        if let respondedInterrupt = interruptFlag.findFirstRespondedInterrupt(using: gb.cpu.interruptEnable) {
            gb.cpu.stackPointer -= 1
            gb.write(UInt8(gb.cpu.programCounter >> 8), to: gb.cpu.stackPointer)
            gb.cpu.stackPointer -= 1
            gb.write(UInt8(gb.cpu.programCounter & 0xFF), to: gb.cpu.stackPointer)
            gb.cpu.programCounter = respondedInterrupt.address
            
            interruptFlag.unset(respondedInterrupt)
            gb.cpu.interruptMasterEnabled = false
            gb.write(interruptFlag.value, to: 0xFF0F)
        }
    }
}
