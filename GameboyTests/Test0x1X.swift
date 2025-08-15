//
//  Test0x1X.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 9/8/2568 BE.
//

import Testing
import Gameboy

struct Test0x1X {
    
    @Test func opcode0x11() async throws {
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x11]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 2)
        #expect(cpu.registerDE.all == 0xCDAB)
    }
    
    @Test func opcode0x12() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        /// Load from register
        cpu.registerAF.hi = 0xAA
        /// Load to address in register
        cpu.registerDE.all = 0xBCBC
        
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x12]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(memory[0xBCBC] == 0xAA)
    }
    
    @Test func opcode0x13() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xABCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x13]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xABCE)
        #expect(cpu.registerAF.lo == 0x0)
    }
    
    @Test func opcode0x14() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xABCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x14]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xACCD)
        #expect(cpu.registerAF.lo == 0x0)
    }
    
    @Test func opcode0x14_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xFFCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x14]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0x00CD)
        #expect(cpu.registerAF.lo == 0b1010_0000)
    }
    
    @Test func opcode0x14_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0x0FCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x14]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0x10CD)
        #expect(cpu.registerAF.lo == 0b0010_0000)
    }
    
    @Test func opcode0x15() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xABCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x15]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xAACD)
        #expect(cpu.registerAF.lo == 0b0100_0000)
    }
    
    @Test func opcode0x15_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0x01CD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x15]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0x00CD)
        #expect(cpu.registerAF.lo == 0b1100_0000)
    }
    
    @Test func opcode0x15_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0x10CD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x15]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0x0FCD)
        #expect(cpu.registerAF.lo == 0b0110_0000)
    }
    
    @Test func opcode0x16() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xABCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x16]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 1)
        #expect(cpu.registerDE.all == 0xDECD)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }

    @Test func opcode0x18() async throws {
        var cpu = CPU()
        cpu.programCounter = 0x30
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return 0xFA
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x18]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0x30 + 1 + Int8(bitPattern: UInt8(0xFA)))
    }
    
    @Test func opcode0x17_1() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       10001001
        /// 1           :       00010011        after
        
        var cpu = CPU()
        cpu.registerAF.hi = 0b10001001
        cpu.updateFlag(
            ALU.Flag(
                zero: .noneAffected,
                subtract: .noneAffected,
                halfCarry: .noneAffected,
                carry: .some(true)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x17]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == true)
        #expect(cpu.registerAF.hi == 0b00010011)
        #expect(cpu.registerAF.lo == 0b00010000)
    }
    
    @Test func opcode0x17_2() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010011        after
        
        var cpu = CPU()
        cpu.registerAF.hi = 0b01001001
        cpu.updateFlag(
            ALU.Flag(
                zero: .noneAffected,
                subtract: .noneAffected,
                halfCarry: .noneAffected,
                carry: .some(true)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x17]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == false)
        #expect(cpu.registerAF.hi == 0b10010011)
        #expect(cpu.registerAF.lo == 0b00000000)
    }
    
    @Test func opcode0x19() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xAB00
        cpu.registerDE.all = 0x00DE
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x19]
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
    
    @Test func opcode0x19_Zero_Not_Set() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xFFFF
        cpu.registerDE.all = 0x0001
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x19]
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
    
    @Test func opcode0x19_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xA1B0
        cpu.registerDE.all = 0x0F0E
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x19]
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
    
    @Test func opcode0x19_Carry() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerHL.all = 0xA1B0
        cpu.registerDE.all = 0xFF0E
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x19]
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
    
    @Test func opcode0x1A() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerAF.hi = 0xAB
        cpu.registerDE.all = 0xFF0E
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1A]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerAF.all == 0x0300)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x1B() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xABAB
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1B]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xABAA)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x1B_Flag() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0x0001
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1B]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0x0000)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x1C() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xABCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xABCE)
        #expect(cpu.registerAF.lo == 0x0)
    }
    
    @Test func opcode0x1C_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xCDFF
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xCD00)
        #expect(cpu.registerAF.lo == 0b1010_0000)
    }
    
    @Test func opcode0x1C_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xCD0F
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xCD10)
        #expect(cpu.registerAF.lo == 0b0010_0000)
    }
    
    @Test func opcode0x1D() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xABCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xABCC)
        #expect(cpu.registerAF.lo == 0b0100_0000)
    }
    
    @Test func opcode0x1D_Zero() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xCD01
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xCD00)
        #expect(cpu.registerAF.lo == 0b1100_0000)
    }
    
    @Test func opcode0x1D_Half() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xCD10
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 0)
        #expect(cpu.registerDE.all == 0xCD0F)
        #expect(cpu.registerAF.lo == 0b0110_0000)
    }
    
    @Test func opcode0x1E() async throws {
        var cpu = CPU()
        cpu.programCounter = 0
        cpu.registerDE.all = 0xABCD
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
        
        let instructionBuilder = InstructionBuilder.instructions[0x1E]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.programCounter == 1)
        #expect(cpu.registerDE.all == 0xABDE)
        #expect(cpu.registerAF.lo == 0b0000_0000)
    }
    
    @Test func opcode0x1F_1() async throws {
        /// expect
        /// carry     :       A register        before
        /// 0           :       10001001
        /// 1           :       01000100        after
        
        var cpu = CPU()
        cpu.registerAF.hi = 0b10001001
        cpu.updateFlag(
            ALU.Flag(
                zero: .noneAffected,
                subtract: .noneAffected,
                halfCarry: .noneAffected,
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x1F]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == true)
        #expect(cpu.registerAF.hi == 0b01000100)
        #expect(cpu.registerAF.lo == 0b00010000)
    }
    
    @Test func opcode0x1F_2() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001000
        /// 0           :       10100100        after
        
        var cpu = CPU()
        cpu.registerAF.hi = 0b01001000
        cpu.updateFlag(
            ALU.Flag(
                zero: .noneAffected,
                subtract: .noneAffected,
                halfCarry: .noneAffected,
                carry: .some(true)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.instructions[0x1F]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == false)
        #expect(cpu.registerAF.hi == 0b10100100)
        #expect(cpu.registerAF.lo == 0b00000000)
    }
}
