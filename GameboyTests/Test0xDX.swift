//
//  Test0xDX.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 9/8/2568 BE.
//

import Testing
import Gameboy

struct Test0xDX {
    
    @Test func opcode0xD0_RET() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        cpu.updateFlag(ALU.Flag(
            zero: .noneAffected,
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .some(false)
        ))
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xD0]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0xFFFA)
        #expect(cpu.stackPointer == 2)
    }

    @Test func opcode0xD0_NOTRET() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        cpu.updateFlag(ALU.Flag(
            zero: .noneAffected,
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .some(true)
        ))
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xD0]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30)
        #expect(cpu.stackPointer == 0)
    }

    @Test func opcode0xD4_CALL() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 2
        cpu.updateFlag(ALU.Flag(
            zero: .noneAffected,
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .some(false)
        ))
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return 0xFA
            } else if programCounter == 1 {
                programCounter += 1
                return 0xFF
            }
            return 0xFF
        }
        
        var stack = [UInt8](repeating: 0x00, count: 0x2)
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            stack[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xD4]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0xFFFA)
        #expect(cpu.stackPointer == 0)
        #expect(stack == [0x32, 0x0])
    }

    @Test func opcode0xD4_NOTCALL() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 2
        cpu.updateFlag(ALU.Flag(
            zero: .noneAffected,
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .some(true)
        ))
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return 0xFA
            } else if programCounter == 1 {
                programCounter += 1
                return 0xFF
            }
            return 0xFF
        }
        
        var stack = [UInt8](repeating: 0x00, count: 0x2)
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            stack[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xD4]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x32)
        #expect(cpu.stackPointer == 2)
        #expect(stack == [0x0, 0x0])
    }
    
    @Test func opcode0xD8_RET() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        cpu.updateFlag(ALU.Flag(
            zero: .noneAffected,
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .some(true)
        ))
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xD8]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0xFFFA)
        #expect(cpu.stackPointer == 2)
    }

    @Test func opcode0xD8_NOTRET() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        cpu.updateFlag(ALU.Flag(
            zero: .noneAffected,
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .some(false)
        ))
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xD8]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30)
        #expect(cpu.stackPointer == 0)
    }
    
    @Test func opcode0xD9() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        cpu.updateFlag(ALU.Flag(
            zero: .noneAffected,
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .some(true)
        ))
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xD9]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0xFFFA)
        #expect(cpu.stackPointer == 2)
        #expect(cpu.interruptMasterEnabled == true)
    }
    
    @Test func opcode0xDC_CALL() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 2
        cpu.updateFlag(ALU.Flag(
            zero: .noneAffected,
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .some(true)
        ))
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return 0xFA
            } else if programCounter == 1 {
                programCounter += 1
                return 0xFF
            }
            return 0xFF
        }
        
        var stack = [UInt8](repeating: 0x00, count: 0x2)
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            stack[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xDC]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0xFFFA)
        #expect(cpu.stackPointer == 0)
        #expect(stack == [0x32, 0x0])
    }

    @Test func opcode0xDC_NOTCALL() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 2
        cpu.updateFlag(ALU.Flag(
            zero: .noneAffected,
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .some(false)
        ))
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return 0xFA
            } else if programCounter == 1 {
                programCounter += 1
                return 0xFF
            }
            return 0xFF
        }
        
        var stack = [UInt8](repeating: 0x00, count: 0x2)
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            stack[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xDC]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x32)
        #expect(cpu.stackPointer == 2)
        #expect(stack == [0x0, 0x0])
    }
}
