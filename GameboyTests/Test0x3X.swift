//
//  Test0x3X.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 9/8/2568 BE.
//

import Testing
import Gameboy

struct Test0x3X {

    @Test func opcode0x30_Jump() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
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
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x30]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30 + 1 + Int8(bitPattern: UInt8(0xFA)))
    }

    @Test func opcode0x30_NotJump() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
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
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x30]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30 + 1)
    }
    
    @Test func opcode0x31() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.stackPointer = 0
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x31]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 2)
        #expect(cpu.stackPointer == 0xCDAB)
    }
    
    @Test func opcode0x32() async throws {
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x32]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(memory[0xBCBC] == 0xAA)
        #expect(cpu.registerHL.all == 0xBCBB)
    }
    
    @Test func opcode0x33() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.stackPointer = 0xABCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x33]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.stackPointer == 0xABCE)
        #expect(cpu.registerAF.lo == 0x0)
    }
    
    @Test func opcode0x34() async throws {
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
        
        var memory: [UInt8] = Array(repeating: 0, count: 0xFFFF)
        let readMemory: (UInt16) -> UInt8 = { address in
            return memory[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            memory[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x34]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(memory[0xABCD] == 1)
        #expect(cpu.registerAF.lo == 0x0)
    }
    
    @Test func opcode0x34_Zero() async throws {
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
        var memory: [UInt8] = Array(repeating: 0, count: 0xFFFF)
        memory[0xFFCD] = 0xFF
        let readMemory: (UInt16) -> UInt8 = { address in
            return memory[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            memory[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x34]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(memory[0xFFCD] == 0x00)
        #expect(cpu.registerAF.lo == 0b1010_0000)
    }
    
    @Test func opcode0x34_Half() async throws {
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
        var memory: [UInt8] = Array(repeating: 0, count: 0xFFFF)
        memory[0x0FCD] = 0x0F
        let readMemory: (UInt16) -> UInt8 = { address in
            return memory[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            memory[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x34]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(memory[0x0FCD] == 0x10)
        #expect(cpu.registerAF.lo == 0b0010_0000)
    }
    
    @Test func opcode0x35() async throws {
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
        var memory: [UInt8] = Array(repeating: 0, count: 0xFFFF)
        memory[0xABCD] = 0x0F
        let readMemory: (UInt16) -> UInt8 = { address in
            return memory[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            memory[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x35]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(memory[0xABCD] == 0x0E)
        #expect(cpu.registerAF.lo == 0b0100_0000)
    }
    
    @Test func opcode0x35_Zero() async throws {
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
        var memory: [UInt8] = Array(repeating: 0, count: 0xFFFF)
        memory[0x01CD] = 0x01
        let readMemory: (UInt16) -> UInt8 = { address in
            return memory[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            memory[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x35]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(memory[0x0FCD] == 0x0)
        #expect(cpu.registerAF.lo == 0b1100_0000)
    }
    
    @Test func opcode0x35_Half() async throws {
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
        var memory: [UInt8] = Array(repeating: 0, count: 0xFFFF)
        memory[0x10CD] = 0x10
        let readMemory: (UInt16) -> UInt8 = { address in
            return memory[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            memory[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x35]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(memory[0x10CD] == 0x0F)
        #expect(cpu.registerAF.lo == 0b0110_0000)
    }
    
    @Test func opcode0x36() async throws {
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
        var memory: [UInt8] = Array(repeating: 0, count: 0xFFFF)
        memory[0xABCD] = 0x10
        memory[0x0] = 0xDE
        let readMemory: (UInt16) -> UInt8 = { address in
            return memory[Int(address)]
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { value, address in
            memory[Int(address)] = value
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x36]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 1)
        #expect(memory[0xABCD] == 0xDE)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x38_Jump() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x01
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
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x38]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 65532)
    }

    @Test func opcode0x38_NotJump() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
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
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x38]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30 + 1)
    }
    
    @Test func opcode0x39() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xAB00
        cpu.stackPointer = 0x00DE
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x39]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xABDE)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x39_Zero_Not_Set() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xFFFF
        cpu.stackPointer = 0x0001
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x39]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0x0)
        #expect(cpu.registerAF.lo == 0b0011_0000)
    }
    
    @Test func opcode0x39_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xA1B0
        cpu.stackPointer = 0x0F0E
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x39]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xB0BE)
        #expect(cpu.registerAF.lo == 0b0010_0000)
    }
    
    @Test func opcode0x39_Carry() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xA1B0
        cpu.stackPointer = 0xFF0E
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x39]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerHL.all == 0xA0BE)
        #expect(cpu.registerAF.lo == 0b0011_0000)
    }
    
    @Test func opcode0x3A() async throws {
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3A]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.all == 0x0300)
        #expect(cpu.registerAF.lo == 0b0000_0000)
        #expect(cpu.registerHL.all == 0xFF0D)
    }
    
    @Test func opcode0x3B() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.stackPointer = 0xABAB
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3B]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.stackPointer == 0xABAA)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x3B_Flag() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.stackPointer = 0x0001
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3B]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.stackPointer == 0x0000)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x3C() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.all = 0xABC0
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.hi == 0xAC)
        #expect(cpu.registerAF.lo == 0x0)
    }
    
    @Test func opcode0x3C_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.all = 0xFFC0
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.hi == 0x00)
        #expect(cpu.registerAF.lo == 0b1010_0000)
    }
    
    @Test func opcode0x3C_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.all = 0x0FCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.hi == 0x10)
        #expect(cpu.registerAF.lo == 0b0010_0000)
    }
    
    @Test func opcode0x3D() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.all = 0xAB00
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.hi == 0xAA)
        #expect(cpu.registerAF.lo == 0b0100_0000)
    }
    
    @Test func opcode0x3D_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.all = 0x0100
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.hi == 0x0)
        #expect(cpu.registerAF.lo == 0b1100_0000)
    }
    
    @Test func opcode0x3D_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.all = 0x1000
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.hi == 0x0F)
        #expect(cpu.registerAF.lo == 0b0110_0000)
    }
    
    @Test func opcode0x3E() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.all = 0xABCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x3E]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 1)
        #expect(cpu.registerAF.all == 0xDE00)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x3F() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xDE
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x3F]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.lo == 0b1001_0000)
    }
    
    @Test func opcode0x3F_1() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(true)
            )
        )
        let readMemory: (UInt16) -> UInt8 = { _ in
            return 0xDE
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x3F]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.lo == 0b1000_0000)
    }
}
