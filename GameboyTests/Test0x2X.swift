//
//  Test0x2X.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 9/8/2568 BE.
//

import Testing
import Gameboy

struct Test0x2X {

    @Test func opcode0x20_Jump() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.updateFlag(ALU.Flag(
            zero: .some(false),
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .noneAffected
        ))
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return 0xFA
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x20]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30 + 1 + Int8(bitPattern: UInt8(0xFA)))
    }

    @Test func opcode0x20_NotJump() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.updateFlag(ALU.Flag(
            zero: .some(true),
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .noneAffected
        ))
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return 0xFA
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x20]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30 + 1)
    }
    
    @Test func opcode0x28_Jump() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.updateFlag(ALU.Flag(
            zero: .some(true),
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .noneAffected
        ))
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return 0xFA
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x28]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30 + 1 + Int8(bitPattern: UInt8(0xFA)))
    }

    @Test func opcode0x28_NotJump() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.updateFlag(ALU.Flag(
            zero: .some(false),
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .noneAffected
        ))
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return 0xFA
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x28]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30 + 1)
    }
}
