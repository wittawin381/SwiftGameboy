//
//  Test0x0X_Prefix.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 12/8/2568 BE.
//

import Testing
import Gameboy

struct Test0x0X_Prefix {

    @Test func opcode0x00_1() async throws {
        /// expect
        /// carry     :       A register        before
        /// 0           :       1000_1001
        /// 1           :       0001_0011        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b1000_1001
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
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x00]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == true)
        #expect(cpu.registerBC.hi == 0b0001_0011)
        #expect(cpu.registerAF.lo == 0b0001_0000)
    }
    
    @Test func opcode0x00_Shift_Equal_Zero() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       0000_0000
        /// 0           :       0000_0000        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0000_0000
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
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x00]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == false)
        #expect(cpu.registerBC.hi == 0b0000_0000)
        #expect(cpu.registerAF.lo == 0b1000_0000)
    }
    
    @Test func opcode0x00_2() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b01001001
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
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x00]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == false)
        #expect(cpu.registerBC.hi == 0b10010010)
        #expect(cpu.registerAF.lo == 0b00000000)
    }

    @Test func opcode0x01_1() async throws {
        /// expect
        /// carry     :       A register        before
        /// 0           :       1000_1001
        /// 1           :       0001_0011        after
        
        var cpu = CPU()
        cpu.registerBC.lo = 0b1000_1001
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
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x01]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == true)
        #expect(cpu.registerBC.lo == 0b0001_0011)
        #expect(cpu.registerAF.lo == 0b0001_0000)
    }
    
    @Test func opcode0x01_Shift_Equal_Zero() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       0000_0000
        /// 0           :       0000_0000        after
        
        var cpu = CPU()
        cpu.registerBC.lo = 0000_0000
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
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x01]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == false)
        #expect(cpu.registerBC.lo == 0b0000_0000)
        #expect(cpu.registerAF.lo == 0b1000_0000)
    }
    
    @Test func opcode0x01_2() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.lo = 0b01001001
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
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x01]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == false)
        #expect(cpu.registerBC.lo == 0b10010010)
        #expect(cpu.registerAF.lo == 0b00000000)
    }
    
    @Test func opcode0x3C() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerHL.hi = 0b01001001
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(true)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x3C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.carryFlag == true)
        #expect(cpu.registerHL.hi == 0b00100100)
        #expect(cpu.registerAF.lo == 0b00010000)
    }
    
    @Test func opcode0x40() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b01001001
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x40]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerAF.lo == 0b00100000)
    }
    
    @Test func opcode0x40_1() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b01001000
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x40]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerAF.lo == 0b10100000)
    }
    
    @Test func opcode0x80() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b01001001
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x80]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi == 0b01001000)
    }
    
    @Test func opcode0x88() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b01001011
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x88]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi == 0b01001001)
    }
    
    @Test func opcode0x90() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b01001111
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x90]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi == 0b01001011)
    }
    
    @Test func opcode0x98() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b01011111
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0x98]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi == 0b01010111)
    }
    
    @Test func opcode0xC0() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b01011110
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0xC0]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi == 0b01011111)
    }
    
    @Test func opcode0xF8() async throws {
        /// expect
        /// carry     :       A register        before
        /// 1           :       01001001
        /// 0           :       10010010        after
        
        var cpu = CPU()
        cpu.registerBC.hi = 0b01011110
        cpu.updateFlag(
            ALU.Flag(
                zero: .some(true),
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .some(false)
            )
        )
        
        let readMemory: (UInt16) -> UInt8 = { _ in
            0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = { _, _ in
            
        }
        
        let instructionBuilder = InstructionBuilder.prefixInstruction[0xF8]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi == 0b11011110)
    }
}
