//
//  Test0x6X.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 9/8/2568 BE.
//

import Testing
import Gameboy

struct Test0x6X {

    @Test func opcode0x60() async throws {
        var cpu = CPU()
        cpu.registerBC.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x60]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.hi != 0)
        #expect(cpu.registerHL.hi == cpu.registerBC.hi)
        #expect(cpu.programCounter == 0)
    }

    @Test func opcode0x61() async throws {
        var cpu = CPU()
        cpu.registerBC.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x61]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.hi != 0)
        #expect(cpu.registerHL.hi == cpu.registerBC.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x62() async throws {
        var cpu = CPU()
        cpu.registerDE.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x62]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.hi != 0)
        #expect(cpu.registerHL.hi == cpu.registerDE.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x63() async throws {
        var cpu = CPU()
        cpu.registerDE.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x63]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.hi != 0)
        #expect(cpu.registerHL.hi == cpu.registerDE.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x64() async throws {
        var cpu = CPU()
        cpu.registerHL.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x64]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.hi != 0)
        #expect(cpu.registerHL.hi == cpu.registerHL.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x65() async throws {
        var cpu = CPU()
        cpu.registerHL.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x65]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.hi != 0)
        #expect(cpu.registerHL.hi == cpu.registerHL.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x66() async throws {
        var cpu = CPU()
        cpu.registerHL.all = 0xFFAB
        
        let readMemory: (UInt16) -> UInt8 = { address in
            if address == 0xFFAB {
                return 0x08
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x66]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.hi == 0x08)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x67() async throws {
        var cpu = CPU()
        cpu.registerAF.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x67]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.hi != 0)
        #expect(cpu.registerHL.hi == cpu.registerAF.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x68() async throws {
        var cpu = CPU()
        cpu.registerBC.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x68]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.lo != 0)
        #expect(cpu.registerHL.lo == cpu.registerBC.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x69() async throws {
        var cpu = CPU()
        cpu.registerBC.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x69]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.lo != 0)
        #expect(cpu.registerHL.lo == cpu.registerBC.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x6A() async throws {
        var cpu = CPU()
        cpu.registerDE.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x6A]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.lo != 0)
        #expect(cpu.registerHL.lo == cpu.registerDE.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x6B() async throws {
        var cpu = CPU()
        cpu.registerDE.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x6B]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.lo != 0)
        #expect(cpu.registerHL.lo == cpu.registerDE.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x6C() async throws {
        var cpu = CPU()
        cpu.registerHL.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x6C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.lo != 0)
        #expect(cpu.registerHL.lo == cpu.registerHL.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x6D() async throws {
        var cpu = CPU()
        cpu.registerHL.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x6D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.lo != 0)
        #expect(cpu.registerHL.lo == cpu.registerHL.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x6E() async throws {
        var cpu = CPU()
        cpu.registerHL.all = 0xFFAB
        
        let readMemory: (UInt16) -> UInt8 = { address in
            if address == 0xFFAB {
                return 0x08
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x6E]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.lo == 0x08)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x6F() async throws {
        var cpu = CPU()
        cpu.registerAF.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x6F]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerHL.lo != 0)
        #expect(cpu.registerHL.lo == cpu.registerAF.hi)
        #expect(cpu.programCounter == 0)
    }
}
