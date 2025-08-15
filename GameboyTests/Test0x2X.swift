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
    
    @Test func opcode0x21() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        var pc = 0
        let readMemory: (UInt16) -> UInt8 = { _ in
            pc += 1
            if pc == 1 {
                return 0xAB
            } else if pc == 2 {
                return 0xCD
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x21]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 2)
        #expect(cpu.registerHL.all == 0xCDAB)
    }
    
    @Test func opcode0x22() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        /// Load from register
        cpu.registerAF.hi = 0xAA
        /// Load to address in register
        cpu.registerHL.all = 0xBCBC
        
        var pc = 0
        let readMemory: (UInt16) -> UInt8 = { _ in
            pc += 1
            if pc == 1 {
                return 0xAB
            } else if pc == 2 {
                return 0xCD
            }
            return 0xFF
        }
        
        var memory: [UInt8] = Array(repeating: 0x00, count: 0xFFFF)
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            memory[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x22]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(memory[0xBCBC] == 0xAA)
        #expect(cpu.registerHL.all == 0xBCBD)
    }
    
    @Test func opcode0x23() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xABCD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x23]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xABCE)
        #expect(cpu.registerAF.lo == 0x0)
    }
    
    @Test func opcode0x24() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xABCD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x24]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xACCD)
        #expect(cpu.registerAF.lo == 0x0)
    }
    
    @Test func opcode0x24_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xFFCD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x24]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0x00CD)
        #expect(cpu.registerAF.lo == 0b1010_0000)
    }
    
    @Test func opcode0x24_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0x0FCD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x24]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0x10CD)
        #expect(cpu.registerAF.lo == 0b0010_0000)
    }
    
    @Test func opcode0x25() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xABCD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x25]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xAACD)
        #expect(cpu.registerAF.lo == 0b0100_0000)
    }
    
    @Test func opcode0x25_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0x01CD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x25]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0x00CD)
        #expect(cpu.registerAF.lo == 0b1100_0000)
    }
    
    @Test func opcode0x25_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0x10CD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x25]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0x0FCD)
        #expect(cpu.registerAF.lo == 0b0110_0000)
    }
    
    @Test func opcode0x26() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xABCD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xDE
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x26]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 1)
        #expect(cpu.registerHL.all == 0xDECD)
        #expect(cpu.registerAF.lo == 0b0000_0000)
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
    
    @Test func opcode0x29() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0x00A0
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x29]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0x0140)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x29_Zero_Not_Set() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0x8000
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x29]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0x0)
        #expect(cpu.registerAF.lo == 0b0001_0000)
    }
    
    @Test func opcode0x29_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0x0F00
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x29]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0x1E00)
        #expect(cpu.registerAF.lo == 0b0010_0000)
    }
    
    @Test func opcode0x29_Carry() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xF000
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x29]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xE000)
        #expect(cpu.registerAF.lo == 0b0001_0000)
    }
    
    @Test func opcode0x2A() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.hi = 0xAB
        cpu.registerHL.all = 0xFF0E
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        
        var memory: [UInt8] = Array(repeating: 0, count: 0xFFFF)
        memory[0xFF0E] = 0x03
        
        let readMemory: (UInt16) -> UInt8 = { address in
            return memory[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            memory[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2A]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.all == 0x0300)
        #expect(cpu.registerAF.lo == 0b0000_0000)
        #expect(cpu.registerHL.all == 0xFF0F)
    }
    
    @Test func opcode0x2B() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xABAB
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { address in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2B]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xABAA)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x2B_Flag() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0x0001
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { address in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2B]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0x0000)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x2C() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xABCD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xABCE)
        #expect(cpu.registerAF.lo == 0x0)
    }
    
    @Test func opcode0x2C_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xCDFF
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xCD00)
        #expect(cpu.registerAF.lo == 0b1010_0000)
    }
    
    @Test func opcode0x2C_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xCD0F
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xCD10)
        #expect(cpu.registerAF.lo == 0b0010_0000)
    }
    
    @Test func opcode0x2D() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xABCD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xABCC)
        #expect(cpu.registerAF.lo == 0b0100_0000)
    }
    
    @Test func opcode0x2D_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xCD01
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xCD00)
        #expect(cpu.registerAF.lo == 0b1100_0000)
    }
    
    @Test func opcode0x2D_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xCD10
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xCD0F)
        #expect(cpu.registerAF.lo == 0b0110_0000)
    }
    
    @Test func opcode0x2E() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xABCD
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xDE
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2E]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 1)
        #expect(cpu.registerHL.all == 0xABDE)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x2F() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.all = 0xAB00
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xDE
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x2F]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.hi == 0x54)
        #expect(cpu.registerAF.lo == 0b1110_0000)
    }
}
