//
//  GameboyTests.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 9/8/2568 BE.
//

import Testing
import Gameboy

struct GameboyTests {

    @Test func opcode0x01() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        let result = loadRRnn(instruction: 0x01)
        
        #expect(result.cpu.registerBC.all == result.result)
        #expect(result.cpu.programCounter == result.programCounter)
    }
    
    @Test func opcode0x11() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        let result = loadRRnn(instruction: 0x11)
        
        #expect(result.cpu.registerDE.all == result.result)
        #expect(result.cpu.programCounter == result.programCounter)
    }
    
    @Test func opcode0x21() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        let result = loadRRnn(instruction: 0x21)
        
        #expect(result.cpu.registerHL.all == result.result)
        #expect(result.cpu.programCounter == result.programCounter)
    }
    
    @Test func opcode0x31() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        let result = loadRRnn(instruction: 0x31)
        
        #expect(result.cpu.stackPointer == result.result)
        #expect(result.cpu.programCounter == result.programCounter)
    }
    
    @Test func opcode0x41() async throws {
        let result = loadRR(instruction: 0x41)
        
        #expect(result.cpu.registerBC.hi != 0)
        #expect(result.cpu.registerBC.hi == result.cpu.registerBC.lo)
        #expect(result.cpu.programCounter == result.programCounter)
    }
    
    @Test func opcode0x42() async throws {
        var cpu = CPU()
        cpu.registerDE.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x42]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi != 0)
        #expect(cpu.registerBC.hi == cpu.registerDE.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x43() async throws {
        var cpu = CPU()
        cpu.registerDE.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x43]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi != 0)
        #expect(cpu.registerBC.hi == cpu.registerDE.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x44() async throws {
        var cpu = CPU()
        cpu.registerHL.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x44]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi != 0)
        #expect(cpu.registerBC.hi == cpu.registerHL.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x45() async throws {
        var cpu = CPU()
        cpu.registerHL.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x45]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi != 0)
        #expect(cpu.registerBC.hi == cpu.registerHL.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x46() async throws {
        var cpu = CPU()
        cpu.registerHL.all = 0xFFAB
        
        let readMemory: (UInt16) -> UInt8 = { address in
            if address == 0xFFAB {
                return 0x08
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x46]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi == 0x08)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x47() async throws {
        var cpu = CPU()
        cpu.registerAF.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x47]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.hi != 0)
        #expect(cpu.registerBC.hi == cpu.registerAF.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x48() async throws {
        var cpu = CPU()
        cpu.registerBC.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x48]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.lo != 0)
        #expect(cpu.registerBC.lo == cpu.registerBC.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x49() async throws {
        var cpu = CPU()
        cpu.registerBC.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x49]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.lo != 0)
        #expect(cpu.registerBC.lo == cpu.registerBC.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x4A() async throws {
        var cpu = CPU()
        cpu.registerDE.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x4A]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.lo != 0)
        #expect(cpu.registerBC.lo == cpu.registerDE.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x4B() async throws {
        var cpu = CPU()
        cpu.registerDE.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x4B]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.lo != 0)
        #expect(cpu.registerBC.lo == cpu.registerDE.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x4C() async throws {
        var cpu = CPU()
        cpu.registerHL.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x4C]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.lo != 0)
        #expect(cpu.registerBC.lo == cpu.registerHL.hi)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x4D() async throws {
        var cpu = CPU()
        cpu.registerHL.lo = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x4D]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.lo != 0)
        #expect(cpu.registerBC.lo == cpu.registerHL.lo)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x4E() async throws {
        var cpu = CPU()
        cpu.registerHL.all = 0xFFAB
        
        let readMemory: (UInt16) -> UInt8 = { address in
            if address == 0xFFAB {
                return 0x08
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x4E]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.lo == 0x08)
        #expect(cpu.programCounter == 0)
    }
    
    @Test func opcode0x4F() async throws {
        var cpu = CPU()
        cpu.registerAF.hi = 0x08
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[0x4F]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        
        #expect(cpu.registerBC.lo != 0)
        #expect(cpu.registerBC.lo == cpu.registerAF.hi)
        #expect(cpu.programCounter == 0)
    }
}

extension GameboyTests {
    func loadRRnn(instruction: UInt8) -> (cpu: CPU, programCounter: Int, result: UInt16) {
        var cpu = CPU()

        let lsb = UInt8(0x1)
        let msb = UInt8(0x2)
        
        var programCounter = 0
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            if programCounter == 0 {
                programCounter += 1
                return lsb
            } else if programCounter == 1 {
                programCounter += 1
                return msb
            }
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[instruction]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        return (cpu, programCounter, UInt16(UInt16(msb) << 8 | UInt16(lsb)))
    }
    
    func loadRR(instruction: UInt8) -> (cpu: CPU, programCounter: Int, result: UInt16) {
        var cpu = CPU()
        cpu.registerBC.lo = 0x08
        
        
        let readMemory: (UInt16) -> UInt8 = {_ in
            return 0xFF
        }
        
        let writeMemory: (UInt8, UInt16) -> Void = {_,_ in }
        
        let instructionBuilder = InstructionBuilder.instructions[instruction]
        let instruction = instructionBuilder?.build(
            &cpu,
            readMemory,
            writeMemory
        )
        instruction?.perform(&cpu, readMemory, writeMemory)
        return (cpu, 0, 0x08)
    }
}
