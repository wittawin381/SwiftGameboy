//
//  Test0xCX.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 9/8/2568 BE.
//

import Testing
import Gameboy

struct Test0xCX {
    
    @Test func opcode0xC0_RET() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        cpu.updateFlag(ALU.Flag(
            zero: .some(false),
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .noneAffected
        ))
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xC0]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0xFFFA)
        #expect(cpu.stackPointer == 2)
    }

    @Test func opcode0xC0_NOTRET() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        cpu.updateFlag(ALU.Flag(
            zero: .some(true),
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .noneAffected
        ))
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xC0]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30)
        #expect(cpu.stackPointer == 0)
    }

    @Test func opcode0xC4_CALL() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 2
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
        
        let instructionBuilder = InstructionBuilder.instructions[0xC4]
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

    @Test func opcode0xC4_NOTCALL() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 2
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
        
        let instructionBuilder = InstructionBuilder.instructions[0xC4]
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
    
    @Test func opcode0xC8_RET() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        cpu.updateFlag(ALU.Flag(
            zero: .some(true),
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .noneAffected
        ))
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xC8]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0xFFFA)
        #expect(cpu.stackPointer == 2)
    }

    @Test func opcode0xC8_NOTRET() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        cpu.updateFlag(ALU.Flag(
            zero: .some(false),
            subtract: .noneAffected,
            halfCarry: .noneAffected,
            carry: .noneAffected
        ))
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xC8]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30)
        #expect(cpu.stackPointer == 0)
    }
    
    @Test func opcode0xC9() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 0
        
        let stack: [UInt8] = [0xFA, 0xFF]

        let readMemory: (UInt16) -> UInt8 = { address in
            return stack[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0xC9]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0xFFFA)
        #expect(cpu.stackPointer == 2)
    }
    
    @Test func opcode0xCC_CALL() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 2
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
        
        let instructionBuilder = InstructionBuilder.instructions[0xCC]
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

    @Test func opcode0xCC_NOTCALL() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 2
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
        
        let instructionBuilder = InstructionBuilder.instructions[0xCC]
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
    
    @Test func opcode0xCD() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        cpu.stackPointer = 2
        
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
        
        let instructionBuilder = InstructionBuilder.instructions[0xCD]
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
}
