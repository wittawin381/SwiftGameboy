//
//  Instruction.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 2/7/2568 BE.
//

import Foundation

public typealias MemoryReadHandler = (UInt16) -> UInt8
public typealias MemoryWriteHandler = (UInt8, UInt16) -> Void

public struct InstructionBuilder {
    /// Machine cyle : 1 Machine cycle = 4 clock cycles
    public let build: (inout CPU, MemoryReadHandler, MemoryWriteHandler) -> Instruction
    
    public init(cycles: Int, perform: @escaping (inout CPU, MemoryReadHandler, MemoryWriteHandler) -> Void) {
        self.build = { _, _, _ in
            Instruction(cycles: cycles, perform: perform)
        }
    }
    
    public init(perform: @escaping (inout CPU, MemoryReadHandler, MemoryWriteHandler) -> Instruction) {
        self.build = { cpu, readMemory, writeMemory in
            perform(&cpu, readMemory, writeMemory)
        }
    }
}

public struct Instruction {
    public let cycles: Int
    public let perform: (inout CPU, MemoryReadHandler, MemoryWriteHandler) -> Void
    
    public init(cycles: Int, perform: @escaping (inout CPU, (UInt16) -> UInt8, (UInt8, UInt16) -> Void) -> Void) {
        self.cycles = cycles
        self.perform = perform
    }
}

public extension InstructionBuilder {
    static let instructions: [UInt8: InstructionBuilder] = [
        // MARK: - 0x00
        /// NOP
        0x00: InstructionBuilder(cycles: 1) { _, _, _ in
            /// Do Nothing
        },
        /// LD rr 16 bit
        0x01: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            
            
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerBC.all = value
        },
        /// LD (BC), A
        0x02: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = cpu.registerAF.hi
            
            writeMemory(value, cpu.registerBC.all)
        },
        /// INC rr
        0x03: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.all &+= 1
        },
        /// INC r
        0x04: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerBC.hi)
            cpu.registerBC.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x05: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerBC.hi)
            cpu.registerBC.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x06: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = readMemory(cpu.programCounter)
            cpu.programCounter += 1
        },
        /// RLCA
        0x07: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerAF.hi.bit(7)
            let shiftedValue = (cpu.registerAF.hi << 1) | bit7.toUInt8()
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// LD (nn), SP
        0x08: InstructionBuilder(cycles: 5) { cpu, readMemory, writeMemory in
            let leastSignificantAddressByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantAddressByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let address = (UInt16(mostSignificantAddressByte) << 8) | UInt16(leastSignificantAddressByte)
            
            let leastSignificantDataByte = UInt8(cpu.stackPointer & 0xFF)
            writeMemory(leastSignificantDataByte, address)
            
            let mostSignificantDataByte = UInt8(cpu.stackPointer >> 8)
            writeMemory(mostSignificantDataByte, address + 1)
        },
        /// ADD HL
        0x09: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let result = ALU.add16(cpu.registerHL.all, cpu.registerBC.all, carryBit: 11)
            cpu.registerHL.all = result.value
            cpu.updateFlag(
                ALU.Flag(
                    zero: .noneAffected,
                    subtract: result.flag.subtract,
                    halfCarry: result.flag.halfCarry,
                    carry: result.flag.carry
                )
            )
        },
        /// LD A, (BC) Load to the 8-bit A register, data from the absolute address specified by the 16-bit register BC.
        0x0A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = readMemory(cpu.registerBC.all)
        },
        /// DEC rr
        0x0B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.all &-= 1
        },
        /// INC r
        0x0C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerBC.lo)
            cpu.registerBC.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x0D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerBC.lo)
            cpu.registerBC.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x0E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = readMemory(cpu.programCounter)
            cpu.programCounter += 1
        },
        /// RRCA
        0x0F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerAF.hi.bit(0)
            let shiftedValue = (bit0.toUInt8() << 7) | (cpu.registerAF.hi >> 1)
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        
        // MARK: - 0x01
        /// LD rr 16 bit
        /// TODO: - correctly implement STOP
        0x10: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            cpu.programCounter += 1
        },
        /// LD rr 16 bit
        0x11: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte: UInt8 = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte: UInt8 = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerDE.all = value
        },
        /// LD (DE), A
        0x12: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = cpu.registerAF.hi
            writeMemory(value, cpu.registerDE.all)
        },
        /// INC rr
        0x13: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.all &+= 1
        },
        /// INC r
        0x14: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerDE.hi)
            cpu.registerDE.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x15: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerDE.hi)
            cpu.registerDE.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x16: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = readMemory(cpu.programCounter)
            cpu.programCounter += 1
        },
        /// RLA
        0x17: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = cpu.registerAF.hi.bit(7)
            let shiftedValue = (cpu.registerAF.hi << 1) | carry
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// JR e
        0x18: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let signedValue = Int16(Int8(bitPattern: value))
            let programCounter = Int16(bitPattern: cpu.programCounter)
            let address = programCounter + signedValue
            cpu.programCounter = UInt16(bitPattern: address)
        },
        /// ADD HL
        0x19: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let result = ALU.add16(cpu.registerHL.all, cpu.registerDE.all, carryBit: 11)
            cpu.registerHL.all = result.value
            cpu.updateFlag(
                ALU.Flag(
                    zero: .noneAffected,
                    subtract: result.flag.subtract,
                    halfCarry: result.flag.halfCarry,
                    carry: result.flag.carry
                )
            )
        },
        /// LD A, (BC) Load to the 8-bit A register, data from the absolute address specified by the 16-bit register BC.
        0x1A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerDE.all)
            cpu.registerAF.hi = value
        },
        /// DEC rr
        0x1B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.all &-= 1
        },
        /// INC r
        0x1C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerDE.lo)
            cpu.registerDE.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x1D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerDE.lo)
            cpu.registerDE.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x1E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = readMemory(cpu.programCounter)
            cpu.programCounter += 1
        },
        /// RRA
        0x1F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = cpu.registerAF.hi.bit(0)
            let shiftedValue = (cpu.registerAF.hi >> 1) | (carry << 7)
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        
        // MARK: - 0x02
        /// JR cc, e
        0x20: InstructionBuilder { cpu, readMemory, writeMemory in
            if !cpu.zeroFlag {
                return Instruction(cycles: 3) { cpu, readMemory, writeMemory in
                    let value = readMemory(cpu.programCounter)
                    cpu.programCounter += 1
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return Instruction(cycles: 2) { cpu, readMemory, writeMemory in
                    let _ = readMemory(cpu.programCounter)
                    cpu.programCounter += 1
                }
            }
        },
        /// LD HL rr 16 bit
        0x21: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte: UInt8 = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte: UInt8 = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerHL.all = value
        },
        /// LD (HL+), A
        0x22: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let address = cpu.registerHL.all
            writeMemory(cpu.registerAF.hi, address)
            cpu.registerHL.all &+= 1
        },
        /// INC rr
        0x23: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.all &+= 1
        },
        /// INC r
        0x24: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerHL.hi)
            cpu.registerHL.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x25: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerHL.hi)
            cpu.registerHL.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x26: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = readMemory(cpu.programCounter)
            cpu.programCounter += 1
        },
        /// DAA
        0x27: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            //TODO: - Implement DAA Instruction
        },
        /// JR cc, e
        0x28: InstructionBuilder { cpu, readMemory, writeMemory in
            if cpu.zeroFlag {
                return Instruction(cycles: 3) { cpu, readMemory, writeMemory in
                    let value = readMemory(cpu.programCounter)
                    cpu.programCounter += 1
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return Instruction(cycles: 2) { cpu, readMemory, writeMemory in
                    let _ = readMemory(cpu.programCounter)
                    cpu.programCounter += 1
                }
            }
        },
        /// ADD HL
        0x29: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let result = ALU.add16(cpu.registerHL.all, cpu.registerHL.all, carryBit: 11)
            cpu.registerHL.all = result.value
            cpu.updateFlag(
                ALU.Flag(
                    zero: .noneAffected,
                    subtract: result.flag.subtract,
                    halfCarry: result.flag.halfCarry,
                    carry: result.flag.carry
                )
            )
        },
        /// LD A, (HL+)
        0x2A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let address = cpu.registerHL.all
            cpu.registerAF.hi = readMemory(address)
            cpu.registerHL.all += 1
        },
        /// DEC rr
        0x2B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.all &-= 1
        },
        /// INC r
        0x2C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerHL.lo)
            cpu.registerHL.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x2D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerHL.lo)
            cpu.registerHL.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x2E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = readMemory(cpu.programCounter)
            cpu.programCounter += 1
        },
        /// LDrn Load to 8 bit register r, the data n
        0x2F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = ~cpu.registerAF.hi
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        
        // MARK: - 0x03
        /// JR cc, e
        0x30: InstructionBuilder { cpu, readMemory, writeMemory in
            if !cpu.carryFlag {
                return Instruction(cycles: 3) { cpu, readMemory, writeMemory in
                    let value = readMemory(cpu.programCounter)
                    cpu.programCounter += 1
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return Instruction(cycles: 2) { cpu, readMemory, writeMemory in
                    let _ = readMemory(cpu.programCounter)
                    cpu.programCounter += 1
                }
            }
        },
        /// LD rr 16 bit
        0x31: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte: UInt8 = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte: UInt8 = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.stackPointer = value
        },
        /// LD (HL-), A
        0x32: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let address = cpu.registerHL.all
            writeMemory(cpu.registerAF.hi, address)
            cpu.registerHL.all &-= 1
        },
        /// INC rr
        0x33: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.stackPointer &+= 1
        },
        /// INC HL
        0x34: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let result = ALU.increment(readMemory(cpu.registerHL.all))
            writeMemory(result.value, cpu.registerHL.all)
            cpu.updateFlag(result.flag)
        },
        /// DEC HL
        0x35: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(readMemory(cpu.registerHL.all))
            writeMemory(result.value, cpu.registerHL.all)
            cpu.updateFlag(result.flag)
        },
        /// LD (HL)
        0x36: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            writeMemory(value, cpu.registerHL.all)
        },
        /// SCF
        0x37: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(true)
            )
            cpu.updateFlag(flag)
        },
        /// JR cc, e
        0x38: InstructionBuilder { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            if cpu.carryFlag {
                return Instruction(cycles: 3) { cpu, readMemory, writeMemory in
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter += UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return Instruction(cycles: 2) { _, _, _ in }
            }
        },
        /// ADD HL
        0x39: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let result = ALU.add16(cpu.registerHL.all, cpu.stackPointer, carryBit: 11)
            cpu.registerHL.all = result.value
            cpu.updateFlag(
                ALU.Flag(
                    zero: .noneAffected,
                    subtract: result.flag.subtract,
                    halfCarry: result.flag.halfCarry,
                    carry: result.flag.carry
                )
            )
        },
        /// LD A, (HL-)
        0x3A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let address = cpu.registerHL.all
            cpu.registerAF.hi = readMemory(address)
            cpu.registerHL.all -= 1
        },
        /// DEC rr
        0x3B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.stackPointer &-= 1
        },
        /// INC r
        0x3C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x3D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x3E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = readMemory(cpu.programCounter)
            cpu.programCounter += 1
        },
        /// CCF
        0x3F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(!cpu.carryFlag)
            )
            cpu.updateFlag(flag)
        },
        
        // MARK: - 0x40
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x40: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x41: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x42: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x43: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x44: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x45: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x46: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = readMemory(cpu.registerHL.all)
        },
        /// LDrr`
        0x47: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerAF.hi
        },
        /// LDrr`
        0x48: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.hi
        },
        /// LDrr`
        0x49: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo
        },
        /// LDrr`
        0x4A: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerDE.hi
        },
        /// LDrr`
        0x4B: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerDE.lo
        },
        /// LDrr`
        0x4C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerHL.hi
        },
        /// LDrr`
        0x4D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x4E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = readMemory(cpu.registerHL.all)
        },
        /// LDrr`
        0x4F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerAF.hi
        },
        // MARK: - 0x50
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x50: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x51: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x52: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x53: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x54: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x55: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x56: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = readMemory(cpu.registerHL.all)
        },
        /// LDrr`
        0x57: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerAF.hi
        },
        /// LDrr`
        0x58: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerBC.hi
        },
        /// LDrr`
        0x59: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerBC.lo
        },
        /// LDrr`
        0x5A: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.hi
        },
        /// LDrr`
        0x5B: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo
        },
        /// LDrr`
        0x5C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerHL.hi
        },
        /// LDrr`
        0x5D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x5E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = readMemory(cpu.registerHL.all)
        },
        /// LDrr`
        0x5F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerAF.hi
        },
        
        // MARK: - 0x60
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x60: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x61: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x62: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x63: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x64: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x65: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x66: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = readMemory(cpu.registerHL.all)
        },
        /// LDrr`
        0x67: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerAF.hi
        },
        /// LDrr`
        0x68: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerBC.hi
        },
        /// LDrr`
        0x69: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerBC.lo
        },
        /// LDrr`
        0x6A: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerDE.hi
        },
        /// LDrr`
        0x6B: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerDE.lo
        },
        /// LDrr`
        0x6C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.hi
        },
        /// LDrr`
        0x6D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x6E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = readMemory(cpu.registerHL.all)
        },
        /// LDrr`
        0x6F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerAF.hi
        },
        
        // MARK: - 0x70
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x70: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(cpu.registerBC.hi, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x71: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(cpu.registerBC.lo, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x72: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(cpu.registerDE.hi, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x73: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(cpu.registerDE.lo, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x74: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(cpu.registerHL.hi, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x75: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(cpu.registerHL.lo, cpu.registerHL.all)
        },
        /// TODO: implement correct HALT instruction
        0x76: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.enabled = false
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x77: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(cpu.registerAF.hi, cpu.registerHL.all)
        },
        /// LDrr`
        0x78: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x79: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x7A: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x7B: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x7C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x7D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x7E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = readMemory(cpu.registerHL.all)
        },
        /// LDrr`
        0x7F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi
        },
        
        // MARK: - 0x80
        /// ADD r
        0x80: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x81: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x82: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x83: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x84: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x85: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x86: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let result = ALU.add(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x87: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x88: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x89: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8A: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8B: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC (HL)
        0x8E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let result = ALU.add(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerAF.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        
        // MARK: - 0x90
        /// SUB r
        0x90: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x91: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x92: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x93: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x94: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x95: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x96: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x97: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x98: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x99: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9A: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9B: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9C: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9D: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC HL
        0x9E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let result = ALU.sub(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9F: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // MARK: - 0xA0
        /// AND r
        0xA0: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA1: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA2: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA3: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA4: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA5: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND HL
        0xA6: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let result = ALU.and(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA7: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xA8: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xA9: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAA: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAB: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAC: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAD: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR HL
        0xAE: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let result = ALU.xor(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAF: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        
        // MARK: - 0xB0
        /// OR r
        0xB0: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB1: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB2: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB3: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB4: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB5: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR HL
        0xB6: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let result = ALU.or(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB7: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        
        /// CP r
        0xB8: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xB9: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBA: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBB: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBC: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBD: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.updateFlag(result.flag)
        },
        /// CP HL
        0xBE: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBF: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.updateFlag(result.flag)
        },
        
        // MARK: - 0xC0
        /// RET CC
        0xC0: InstructionBuilder { cpu, readMemory, writeMemory in
            if !cpu.zeroFlag {
                return Instruction(cycles: 5) { cpu, readMemory, writeMemory in
                    let leastSignificantByte = readMemory(cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = readMemory(cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return Instruction(cycles: 2) { _, _, _ in }
            }
        },
        /// POP rr
        0xC1: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerBC.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xC2: InstructionBuilder { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            if !cpu.zeroFlag {
                return Instruction(cycles: 4) { cpu, readMemory, writeMemory in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _, _, _ in }
            }
        },
        /// JP nn
        0xC3: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.programCounter = address
        },
        /// CALL cc, nn
        0xC4: InstructionBuilder { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            if !cpu.zeroFlag {
                return Instruction(cycles: 6) { cpu, readMemory, writeMemory in
                    
                    cpu.stackPointer -= 1
                    writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
                    cpu.stackPointer -= 1
                    writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _, _, _ in }
            }
        },
        /// PUSH rr
        0xC5: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(cpu.registerBC.hi, cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(cpu.registerBC.lo, cpu.stackPointer)
        },
        /// ADD n
        0xC6: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.add(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 00
        0xC7: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x0 | 0x0
        },
        /// RET CC
        0xC8: InstructionBuilder { cpu, readMemory, writeMemory in
            if cpu.zeroFlag {
                return Instruction(cycles: 5) { cpu, readMemory, writeMemory in
                    let leastSignificantByte = readMemory(cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = readMemory(cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return Instruction(cycles: 2) { _, _, _ in }
            }
        },
        /// RET
        0xC9: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xCA: InstructionBuilder { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            if cpu.zeroFlag {
                return Instruction(cycles: 4) { cpu, readMemory, writeMemory in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _, _, _ in }
            }
        },
        /// PREFIX
        0xCB: InstructionBuilder { cpu, readMemory, writeMemory in
            let opcode = readMemory(cpu.programCounter)
//            print(String(format: "%llx %llx", opcode, cpu.programCounter))
            cpu.programCounter += 1
            if let instruction = prefixInstruction[opcode]?.build(&cpu, readMemory, writeMemory) {
                return instruction
            } else {
                fatalError("opcode : \(opcode) hasn't been implemented")
            }
        },
        /// CALL cc, nn
        0xCC: InstructionBuilder { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            if cpu.zeroFlag {
                return Instruction(cycles: 6) { cpu, readMemory, writeMemory in
                    cpu.stackPointer -= 1
                    writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
                    cpu.stackPointer -= 1
                    writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _, _, _ in
                }
            }
        },
        /// CALLCALL nn
        0xCD: InstructionBuilder(cycles: 6) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            
            cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// ADC n
        0xCE: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.add(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 0x08
        0xCF: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x08
        },
        
        // MARK: - 0xD0
        /// RET CC
        0xD0: InstructionBuilder { cpu, readMemory, writeMemory in
            if !cpu.carryFlag {
                return Instruction(cycles: 5) { cpu, readMemory, writeMemory in
                    let leastSignificantByte = readMemory(cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = readMemory(cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return Instruction(cycles: 2) { _, _, _ in }
            }
        },
        /// POP rr
        0xD1: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerDE.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xD2: InstructionBuilder { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            if !cpu.carryFlag {
                return Instruction(cycles: 4) { cpu, readMemory, writeMemory in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _, _, _ in }
            }
        },
        /// CALL cc, nn
        0xD4: InstructionBuilder { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            if !cpu.carryFlag {
                return Instruction(cycles: 6) { cpu, readMemory, writeMemory in
                    cpu.stackPointer -= 1
                    writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
                    cpu.stackPointer -= 1
                    writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _, _, _ in }
            }
        },
        /// PUSH rr
        0xD5: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(cpu.registerDE.hi, cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(cpu.registerDE.lo, cpu.stackPointer)
        },
        /// SUB n
        0xD6: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 10
        0xD7: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x10
        },
        /// RET CC
        0xD8: InstructionBuilder { cpu, readMemory, writeMemory in
            if cpu.carryFlag {
                return Instruction(cycles: 5) { cpu, readMemory, writeMemory in
                    let leastSignificantByte = readMemory(cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = readMemory(cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return Instruction(cycles: 2) { _, _, _ in }
            }
        },
        /// RET CC
        0xD9: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.interruptMasterEnabled = true
        },
        /// JP cc, nn
        0xDA: InstructionBuilder { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            if cpu.carryFlag {
                return Instruction(cycles: 4) { cpu, readMemory, writeMemory in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _, _, _ in }
            }
        },
        /// CALL cc, nn
        0xDC: InstructionBuilder { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            if cpu.carryFlag {
                return Instruction(cycles: 6) { cpu, readMemory, writeMemory in
                    cpu.stackPointer -= 1
                    writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
                    cpu.stackPointer -= 1
                    writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _, _, _ in }
            }
        },
        /// SBC n
        0xDE: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.sub(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 18
        0xDF: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x18
        },
        
        // MARK: - 0xE0
        /// LDH (C), A
        0xE0: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            writeMemory(cpu.registerAF.hi, address)
        },
        /// POP rr
        0xE1: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerHL.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// LDH (C), A
        0xE2: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let leastSignificantByte = cpu.registerBC.lo
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            writeMemory(cpu.registerAF.hi, address)
        },
        /// PUSH rr
        0xE5: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(cpu.registerHL.hi, cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(cpu.registerHL.lo, cpu.stackPointer)
        },
        /// AND n
        0xE6: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.and(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 20
        0xE7: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x20
        },
        /// ADD SP
        0xE8: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let signedValue = Int8(bitPattern: value)
            let halfCarry = ALU.checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 3)
            let carry = ALU.checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 7)
            cpu.stackPointer = cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
            
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(halfCarry),
                carry: .some(carry)
            )
            cpu.updateFlag(flag)
        },
        /// JP nn
        0xE9: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.programCounter = cpu.registerHL.all
        },
        /// LD (nn), A
        0xEA: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            writeMemory(cpu.registerAF.hi, address)
        },
        /// XOR n
        0xEE: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.xor(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 28
        0xEF: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x28
        },
        
        // MARK: - 0xF0
        /// LDH A, (n)
        0xF0: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            let value = readMemory(address)
            cpu.registerAF.hi = value
        },
        /// POP rr
        0xF1: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerAF.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte & 0xF0)
        },
        /// LDH  A, (C)
        0xF2: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let leastSignificantByte = cpu.registerBC.lo
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            cpu.registerAF.hi = readMemory(address)
        },
        /// DI
        0xF3: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.interruptMasterEnabled = false
        },
        /// PUSH rr
        0xF5: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(cpu.registerAF.hi, cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(cpu.registerAF.lo, cpu.stackPointer)
        },
        /// OR n
        0xF6: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.or(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 30
        0xF7: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x30
        },
        /// LD HL, SP+e
        0xF8: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let signedValue = Int8(bitPattern: value)
            let halfCarry = ALU.checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 3)
            let carry = ALU.checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 7)
            cpu.registerHL.all = cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
            cpu.updateFlag(
                ALU.Flag(
                    zero: .some(false),
                    subtract: .some(false),
                    halfCarry: .some(halfCarry),
                    carry: .some(carry)
                )
            )
        },
        /// LD SP, HL
        0xF9: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.stackPointer = cpu.registerHL.all
        },
        /// LD A, (nn)
        0xFA: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerAF.hi = readMemory(address)
        },
        /// DI
        0xFB: InstructionBuilder(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.interruptMasterEnabled = true
        },
        /// CP n
        0xFE: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.updateFlag(result.flag)
        },
        // RST n RST 38
        0xFF: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x38
        },
    ]
    
    static let prefixInstruction: [UInt8: InstructionBuilder] = [
        // MARK: - 0x0
        /// RLC r
        0x00: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerBC.hi.bit(7)
            let shiftedValue = (cpu.registerBC.hi << 1) | bit7.toUInt8()
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RLC r
        0x01: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerBC.lo.bit(7)
            let shiftedValue = (cpu.registerBC.lo << 1) | bit7.toUInt8()
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RLC r
        0x02: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerDE.hi.bit(7)
            let shiftedValue = (cpu.registerDE.hi << 1) | bit7.toUInt8()
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RLC r
        0x03: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerDE.lo.bit(7)
            let shiftedValue = (cpu.registerDE.lo << 1) | bit7.toUInt8()
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RLC r
        0x04: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerHL.hi.bit(7)
            let shiftedValue = (cpu.registerHL.hi << 1) | bit7.toUInt8()
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RLC r
        0x05: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerHL.lo.bit(7)
            let shiftedValue = (cpu.registerHL.lo << 1) | bit7.toUInt8()
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RLC HL
        0x06: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1) | bit7.toUInt8()
            writeMemory(shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RLC r
        0x07: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerAF.hi.bit(7)
            let shiftedValue = (cpu.registerAF.hi << 1) | bit7.toUInt8()
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x08: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerBC.hi.bit(0)
            let shiftedValue = (cpu.registerBC.hi >> 1) | (bit0.toUInt8() << 7)
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x09: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerBC.lo.bit(0)
            let shiftedValue = (cpu.registerBC.lo >> 1) | (bit0.toUInt8() << 7)
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x0A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerDE.hi.bit(0)
            let shiftedValue = (cpu.registerDE.hi >> 1) | (bit0.toUInt8() << 7)
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x0B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerDE.lo.bit(0)
            let shiftedValue = (cpu.registerDE.lo >> 1) | (bit0.toUInt8() << 7)
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x0C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerHL.hi.bit(0)
            let shiftedValue = (cpu.registerHL.hi >> 1) | (bit0.toUInt8() << 7)
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x0D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerHL.lo.bit(0)
            let shiftedValue = (cpu.registerHL.lo >> 1) | (bit0.toUInt8() << 7)
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RRC HL
        0x0E: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (bit0.toUInt8() << 7)
            writeMemory(shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x0F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerAF.hi.bit(0)
            let shiftedValue = (cpu.registerAF.hi >> 1) | (bit0.toUInt8() << 7)
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        // MARK: - 0x1
        /// RRC r
        0x10: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = cpu.registerBC.hi.bit(7)
            let shiftedValue = (cpu.registerBC.hi << 1) | carry
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x11: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = cpu.registerBC.lo.bit(7)
            let shiftedValue = (cpu.registerBC.lo << 1) | carry
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x12: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = cpu.registerDE.hi.bit(7)
            let shiftedValue = (cpu.registerDE.hi << 1) | carry
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x13: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = cpu.registerDE.lo.bit(7)
            let shiftedValue = (cpu.registerDE.lo << 1) | carry
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x14: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = cpu.registerHL.hi.bit(7)
            let shiftedValue = (cpu.registerHL.hi << 1) | carry
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x15: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = cpu.registerHL.lo.bit(7)
            let shiftedValue = (cpu.registerHL.lo << 1) | carry
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RRC HL
        0x16: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1) | carry
            writeMemory(shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x17: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = cpu.registerAF.hi.bit(7)
            let shiftedValue = (cpu.registerAF.hi << 1) | carry
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RR r
        0x18: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = cpu.registerBC.hi.bit(0)
            let shiftedValue = (cpu.registerBC.hi >> 1) | (carry << 7)
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RR r
        0x19: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = cpu.registerBC.lo.bit(0)
            let shiftedValue = (cpu.registerBC.lo >> 1) | (carry << 7)
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RR r
        0x1A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = cpu.registerDE.hi.bit(0)
            let shiftedValue = (cpu.registerDE.hi >> 1) | (carry << 7)
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RR r
        0x1B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = cpu.registerDE.lo.bit(0)
            let shiftedValue = (cpu.registerDE.lo >> 1) | (carry << 7)
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RR r
        0x1C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = cpu.registerHL.hi.bit(0)
            let shiftedValue = (cpu.registerHL.hi >> 1) | (carry << 7)
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RR r
        0x1D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = cpu.registerHL.lo.bit(0)
            let shiftedValue = (cpu.registerHL.lo >> 1) | (carry << 7)
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RR HL
        0x1E: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (carry << 7)
            writeMemory(shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RR r
        0x1F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = cpu.registerAF.hi.bit(0)
            let shiftedValue = (cpu.registerAF.hi >> 1) | (carry << 7)
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        
        // MARK: - 0x2
        /// SLA r
        0x20: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerBC.hi.bit(7)
            let shiftedValue = (cpu.registerBC.hi << 1)
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// SLA r
        0x21: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerBC.lo.bit(7)
            let shiftedValue = (cpu.registerBC.lo << 1)
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// SLA r
        0x22: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerDE.hi.bit(7)
            let shiftedValue = (cpu.registerDE.hi << 1)
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// SLA r
        0x23: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerDE.lo.bit(7)
            let shiftedValue = (cpu.registerDE.lo << 1)
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// SLA r
        0x24: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerHL.hi.bit(7)
            let shiftedValue = (cpu.registerHL.hi << 1)
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// SLA r
        0x25: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerHL.lo.bit(7)
            let shiftedValue = (cpu.registerHL.lo << 1)
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// SLA HL
        0x26: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1)
            writeMemory(shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// SLA r
        0x27: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerAF.hi.bit(7)
            let shiftedValue = (cpu.registerAF.hi << 1)
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// SRA r
        0x28: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerBC.hi.bit(7)
            let bit0 = cpu.registerBC.hi.bit(0)
            let shiftedValue = (cpu.registerBC.hi >> 1) | (bit7.toUInt8() << 7)
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRA r
        0x29: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerBC.lo.bit(7)
            let bit0 = cpu.registerBC.lo.bit(0)
            let shiftedValue = (cpu.registerBC.lo >> 1) | (bit7.toUInt8() << 7)
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRA r
        0x2A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerDE.hi.bit(7)
            let bit0 = cpu.registerDE.hi.bit(0)
            let shiftedValue = (cpu.registerDE.hi >> 1) | (bit7.toUInt8() << 7)
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRA r
        0x2B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerDE.lo.bit(7)
            let bit0 = cpu.registerDE.lo.bit(0)
            let shiftedValue = (cpu.registerDE.lo >> 1) | (bit7.toUInt8() << 7)
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRA r
        0x2C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerHL.hi.bit(7)
            let bit0 = cpu.registerHL.hi.bit(0)
            let shiftedValue = (cpu.registerHL.hi >> 1) | (bit7.toUInt8() << 7)
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRA r
        0x2D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerHL.lo.bit(7)
            let bit0 = cpu.registerHL.lo.bit(0)
            let shiftedValue = (cpu.registerHL.lo >> 1) | (bit7.toUInt8() << 7)
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRA HL
        0x2E: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let bit7 = value.bit(7)
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (bit7.toUInt8() << 7)
            writeMemory(shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRA r
        0x2F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit7 = cpu.registerAF.hi.bit(7)
            let bit0 = cpu.registerAF.hi.bit(0)
            let shiftedValue = (cpu.registerAF.hi >> 1) | (bit7.toUInt8() << 7)
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        
        // MARK: - 0x3
        /// SWAP r
        0x30: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let highNibbles = (cpu.registerBC.hi & 0xF0) >> 4
            let lowNibbles = (cpu.registerBC.hi & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            cpu.registerBC.hi = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            cpu.updateFlag(flag)
        },
        /// SWAP r
        0x31: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let highNibbles = (cpu.registerBC.lo & 0xF0) >> 4
            let lowNibbles = (cpu.registerBC.lo & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            cpu.registerBC.lo = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            cpu.updateFlag(flag)
        },
        /// SWAP r
        0x32: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let highNibbles = (cpu.registerDE.hi & 0xF0) >> 4
            let lowNibbles = (cpu.registerDE.hi & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            cpu.registerDE.hi = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            cpu.updateFlag(flag)
        },
        /// SWAP r
        0x33: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let highNibbles = (cpu.registerDE.lo & 0xF0) >> 4
            let lowNibbles = (cpu.registerDE.lo & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            cpu.registerDE.lo = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            cpu.updateFlag(flag)
        },
        /// SWAP r
        0x34: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let highNibbles = (cpu.registerHL.hi & 0xF0) >> 4
            let lowNibbles = (cpu.registerHL.hi & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            cpu.registerHL.hi = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            cpu.updateFlag(flag)
        },
        /// SWAP r
        0x35: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let highNibbles = (cpu.registerHL.lo & 0xF0) >> 4
            let lowNibbles = (cpu.registerHL.lo & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            cpu.registerHL.lo = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            cpu.updateFlag(flag)
        },
        /// SWAP HL
        0x36: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let highNibbles = (value & 0xF0) >> 4
            let lowNibbles = (value & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            writeMemory(swappedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            cpu.updateFlag(flag)
        },
        /// SWAP r
        0x37: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let highNibbles = (cpu.registerAF.hi & 0xF0) >> 4
            let lowNibbles = (cpu.registerAF.hi & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            cpu.registerAF.hi = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            cpu.updateFlag(flag)
        },
        /// SRL r
        0x38: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerBC.hi.bit(0)
            let shiftedValue = cpu.registerBC.hi >> 1
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRL r
        0x39: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerBC.lo.bit(0)
            let shiftedValue = cpu.registerBC.lo >> 1
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRL r
        0x3A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerDE.hi.bit(0)
            let shiftedValue = cpu.registerDE.hi >> 1
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRL r
        0x3B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerDE.lo.bit(0)
            let shiftedValue = cpu.registerDE.lo >> 1
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRL r
        0x3C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerHL.hi.bit(0)
            let shiftedValue = cpu.registerHL.hi >> 1
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRL r
        0x3D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerHL.lo.bit(0)
            let shiftedValue = cpu.registerHL.lo >> 1
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRL HL
        0x3E: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let bit0 = value.bit(0)
            let shiftedValue = value >> 1
            writeMemory(shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRL r
        0x3F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let bit0 = cpu.registerAF.hi.bit(0)
            let shiftedValue = cpu.registerAF.hi >> 1
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x40: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x41: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x42: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x43: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x44: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x45: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x46: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x47: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x48: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x49: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x4E: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x50: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x51: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x52: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x53: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x54: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x55: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x56: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x57: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x58: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x59: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x5E: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x60: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x61: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x62: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x63: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x64: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x65: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x66: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x67: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x68: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x69: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x6E: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x70: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x71: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x72: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x73: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x74: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x75: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x76: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x77: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x78: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x79: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x7E: InstructionBuilder(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// RES b, r
        0x80: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 0, to: 0)
        },
        /// RES b, r
        0x81: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 0, to: 0)
        },
        /// RES b, r
        0x82: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 0, to: 0)
        },
        /// RES b, r
        0x83: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 0, to: 0)
        },
        /// RES b, r
        0x84: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 0, to: 0)
        },
        /// RES b, r
        0x85: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 0, to: 0)
        },
        /// RES b, HL
        0x86: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 0, to: 0)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0x87: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 0, to: 0)
        },
        /// RES b, r
        0x88: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 1, to: 0)
        },
        /// RES b, r
        0x89: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 1, to: 0)
        },
        /// RES b, r
        0x8A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 1, to: 0)
        },
        /// RES b, r
        0x8B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 1, to: 0)
        },
        /// RES b, r
        0x8C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 1, to: 0)
        },
        /// RES b, r
        0x8D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 1, to: 0)
        },
        /// RES b, HL
        0x8E: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 1, to: 0)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0x8F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 1, to: 0)
        },
        /// RES b, r
        0x90: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 2, to: 0)
        },
        /// RES b, r
        0x91: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 2, to: 0)
        },
        /// RES b, r
        0x92: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 2, to: 0)
        },
        /// RES b, r
        0x93: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 2, to: 0)
        },
        /// RES b, r
        0x94: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 2, to: 0)
        },
        /// RES b, r
        0x95: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 2, to: 0)
        },
        /// RES b, HL
        0x96: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 2, to: 0)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0x97: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 2, to: 0)
        },
        /// RES b, r
        0x98: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 3, to: 0)
        },
        /// RES b, r
        0x99: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 3, to: 0)
        },
        /// RES b, r
        0x9A: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 3, to: 0)
        },
        /// RES b, r
        0x9B: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 3, to: 0)
        },
        /// RES b, r
        0x9C: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 3, to: 0)
        },
        /// RES b, r
        0x9D: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 3, to: 0)
        },
        /// RES b, HL
        0x9E: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 3, to: 0)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0x9F: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 3, to: 0)
        },
        /// RES b, r
        0xA0: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA1: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA2: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA3: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA4: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA5: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 4, to: 0)
        },
        /// RES b, HL
        0xA6: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 4, to: 0)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xA7: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA8: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 5, to: 0)
        },
        /// RES b, r
        0xA9: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 5, to: 0)
        },
        /// RES b, r
        0xAA: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 5, to: 0)
        },
        /// RES b, r
        0xAB: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 5, to: 0)
        },
        /// RES b, r
        0xAC: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 5, to: 0)
        },
        /// RES b, r
        0xAD: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 5, to: 0)
        },
        /// RES b, HL
        0xAE: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 5, to: 0)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xAF: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 5, to: 0)
        },
        /// RES b, r
        0xB0: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB1: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB2: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB3: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB4: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB5: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 6, to: 0)
        },
        /// RES b, HL
        0xB6: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 6, to: 0)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xB7: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB8: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 7, to: 0)
        },
        /// RES b, r
        0xB9: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 7, to: 0)
        },
        /// RES b, r
        0xBA: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 7, to: 0)
        },
        /// RES b, r
        0xBB: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 7, to: 0)
        },
        /// RES b, r
        0xBC: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 7, to: 0)
        },
        /// RES b, r
        0xBD: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 7, to: 0)
        },
        /// RES b, HL
        0xBE: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 7, to: 0)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xBF: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 7, to: 0)
        },
        /// RES b, r
        0xC0: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC1: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC2: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC3: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC4: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC5: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 0, to: 1)
        },
        /// RES b, HL
        0xC6: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 0, to: 1)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xC7: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC8: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 1, to: 1)
        },
        /// RES b, r
        0xC9: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 1, to: 1)
        },
        /// RES b, r
        0xCA: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 1, to: 1)
        },
        /// RES b, r
        0xCB: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 1, to: 1)
        },
        /// RES b, r
        0xCC: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 1, to: 1)
        },
        /// RES b, r
        0xCD: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 1, to: 1)
        },
        /// RES b, HL
        0xCE: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 1, to: 1)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xCF: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 1, to: 1)
        },
        /// RES b, r
        0xD0: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD1: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD2: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD3: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD4: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD5: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 2, to: 1)
        },
        /// RES b, HL
        0xD6: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 2, to: 1)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xD7: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD8: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 3, to: 1)
        },
        /// RES b, r
        0xD9: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 3, to: 1)
        },
        /// RES b, r
        0xDA: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 3, to: 1)
        },
        /// RES b, r
        0xDB: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 3, to: 1)
        },
        /// RES b, r
        0xDC: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 3, to: 1)
        },
        /// RES b, r
        0xDD: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 3, to: 1)
        },
        /// RES b, HL
        0xDE: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 3, to: 1)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xDF: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 3, to: 1)
        },
        /// RES b, r
        0xE0: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE1: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE2: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE3: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE4: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE5: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 4, to: 1)
        },
        /// RES b, HL
        0xE6: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 4, to: 1)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xE7: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE8: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 5, to: 1)
        },
        /// RES b, r
        0xE9: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 5, to: 1)
        },
        /// RES b, r
        0xEA: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 5, to: 1)
        },
        /// RES b, r
        0xEB: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 5, to: 1)
        },
        /// RES b, r
        0xEC: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 5, to: 1)
        },
        /// RES b, r
        0xED: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 5, to: 1)
        },
        /// RES b, HL
        0xEE: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 5, to: 1)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xEF: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 5, to: 1)
        },
        /// RES b, r
        0xF0: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF1: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF2: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF3: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF4: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF5: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 6, to: 1)
        },
        /// RES b, HL
        0xF6: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 6, to: 1)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xF7: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF8: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.updatedBit(at: 7, to: 1)
        },
        /// RES b, r
        0xF9: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.updatedBit(at: 7, to: 1)
        },
        /// RES b, r
        0xFA: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.updatedBit(at: 7, to: 1)
        },
        /// RES b, r
        0xFB: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.updatedBit(at: 7, to: 1)
        },
        /// RES b, r
        0xFC: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.updatedBit(at: 7, to: 1)
        },
        /// RES b, r
        0xFD: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.updatedBit(at: 7, to: 1)
        },
        /// RES b, HL
        0xFE: InstructionBuilder(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu.registerHL.all).updatedBit(at: 7, to: 1)
            writeMemory(value, cpu.registerHL.all)
        },
        /// RES b, r
        0xFF: InstructionBuilder(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.updatedBit(at: 7, to: 1)
        },
    ]
}
