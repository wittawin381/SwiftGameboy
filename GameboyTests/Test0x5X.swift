//
//  Test0x5X.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 9/8/2568 BE.
//

import Testing
import Gameboy

struct Test0x5X {
    @Test func opcode0x50() async throws {
        var cpu = CPU()
        cpu.registerBC.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x50]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.hi != 0)
        #expect(cpu.registerDE.hi == cpu.registerBC.hi)
        #expect(cpu.programCounter == 0)
    }

    @Test func opcode0x51() async throws {
        var cpu = CPU()
        cpu.registerBC.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x51]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.hi != 0)
        #expect(cpu.registerDE.hi == cpu.registerBC.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x52() async throws {
        var cpu = CPU()
        cpu.registerDE.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x52]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.hi != 0)
        #expect(cpu.registerDE.hi == cpu.registerDE.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x53() async throws {
        var cpu = CPU()
        cpu.registerDE.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x53]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.hi != 0)
        #expect(cpu.registerDE.hi == cpu.registerDE.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x54() async throws {
        var cpu = CPU()
        cpu.registerHL.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x54]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.hi != 0)
        #expect(cpu.registerDE.hi == cpu.registerHL.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x55() async throws {
        var cpu = CPU()
        cpu.registerHL.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x55]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.hi != 0)
        #expect(cpu.registerDE.hi == cpu.registerHL.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x56() async throws {
        var cpu = CPU()
        cpu.registerHL.all = 0xFFAB
        
        let readMemory: (UInt16) -> UInt8 = { address in
            if address == 0xFFAB {
                return 0x08
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x56]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.hi == 0x08)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x57() async throws {
        var cpu = CPU()
        cpu.registerAF.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x57]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.hi != 0)
        #expect(cpu.registerDE.hi == cpu.registerAF.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x58() async throws {
        var cpu = CPU()
        cpu.registerBC.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x58]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.lo != 0)
        #expect(cpu.registerDE.lo == cpu.registerBC.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x59() async throws {
        var cpu = CPU()
        cpu.registerBC.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x59]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.lo != 0)
        #expect(cpu.registerDE.lo == cpu.registerBC.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x5A() async throws {
        var cpu = CPU()
        cpu.registerDE.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x5A]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.lo != 0)
        #expect(cpu.registerDE.lo == cpu.registerDE.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x5B() async throws {
        var cpu = CPU()
        cpu.registerDE.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x5B]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.lo != 0)
        #expect(cpu.registerDE.lo == cpu.registerDE.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x5C() async throws {
        var cpu = CPU()
        cpu.registerHL.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x5C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.lo != 0)
        #expect(cpu.registerDE.lo == cpu.registerHL.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x5D() async throws {
        var cpu = CPU()
        cpu.registerHL.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x5D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.lo != 0)
        #expect(cpu.registerDE.lo == cpu.registerHL.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x5E() async throws {
        var cpu = CPU()
        cpu.registerHL.all = 0xFFAB
        
        let readMemory: (UInt16) -> UInt8 = { address in
            if address == 0xFFAB {
                return 0x08
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x5E]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.lo == 0x08)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x5F() async throws {
        var cpu = CPU()
        cpu.registerAF.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x5F]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerDE.lo != 0)
        #expect(cpu.registerDE.lo == cpu.registerAF.hi)
        #expect(cpu.programCounter == 0)
    }

}
