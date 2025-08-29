//
//  InstructionV2.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 30/8/2568 BE.
//

import Foundation

//public struct InstructionBuilderV2V2<Handler: ReadWriteHandler & ~Copyable> {
//    /// Machine cyle : 1 Machine cycle = 4 clock cycles
//    public let build: (inout CPU, inout Handler) -> InstructionV2<Handler>
//    
//    public init(cycles: Int, perform: @escaping (inout CPU, inout Handler) -> Void) {
//        self.build = { _, _ in
//            InstructionV2(cycles: cycles, perform: perform)
//        }
//    }
//    
//    public init(perform: @escaping (inout CPU, inout Handler) -> InstructionV2<Handler>) {
//        self.build = { cpu, readWriteHandler in
//            perform(&cpu, &readWriteHandler)
//        }
//    }
//    
//}

//public struct InstructionV2<Handler: ReadWriteHandler & ~Copyable> {
//    public let cycles: Int
//    public let perform: (inout CPU, inout Handler) -> Void
//    
//    public init(cycles: Int, perform: @escaping (inout CPU, inout Handler) -> Void) {
//        self.cycles = cycles
//        self.perform = perform
//    }
//}

public typealias MemoryReadHandlerV2 = (borrowing CPU, UInt16) -> UInt8
public typealias MemoryWriteHandlerV2 = (inout CPU, UInt8, UInt16) -> Void

public struct InstructionBuilderV2 {
    /// Machine cyle : 1 Machine cycle = 4 clock cycles
    public let build: (inout CPU, MemoryReadHandlerV2, MemoryWriteHandlerV2) -> InstructionV2
    
    public init(cycles: Int, perform: @escaping (inout CPU, MemoryReadHandlerV2, MemoryWriteHandlerV2) -> Void) {
        self.build = { _, _, _ in
            InstructionV2(cycles: cycles, perform: perform)
        }
    }
    
    public init(perform: @escaping (inout CPU, MemoryReadHandlerV2, MemoryWriteHandlerV2) -> InstructionV2) {
        self.build = { cpu, readMemory, writeMemory in
            perform(&cpu, readMemory, writeMemory)
        }
    }
}

public struct InstructionV2 {
    public let cycles: Int
    public let perform: (inout CPU, MemoryReadHandlerV2, MemoryWriteHandlerV2) -> Void
    
    public init(cycles: Int, perform: @escaping (inout CPU, MemoryReadHandlerV2, MemoryWriteHandlerV2) -> Void) {
        self.cycles = cycles
        self.perform = perform
    }
}

public extension InstructionBuilderV2 {
    static let instructions: [UInt8: InstructionBuilderV2] = [
        // MARK: - 0x00
        /// NOP
        0x00: InstructionBuilderV2(cycles: 1) { _, _, _ in
            /// Do Nothing
        },
        /// LD rr 16 bit
        0x01: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            
            
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerBC.all = value
        },
        /// LD (BC), A
        0x02: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = cpu.registerAF.hi
            
            writeMemory(&cpu, value, cpu.registerBC.all)
        },
        /// INC rr
        0x03: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.all &+= 1
        },
        /// INC r
        0x04: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerBC.hi)
            cpu.registerBC.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x05: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerBC.hi)
            cpu.registerBC.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x06: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
        },
        /// RLCA
        0x07: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
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
        0x08: InstructionBuilderV2(cycles: 5) { cpu, readMemory, writeMemory in
            let leastSignificantAddressByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantAddressByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let address = (UInt16(mostSignificantAddressByte) << 8) | UInt16(leastSignificantAddressByte)
            
            let leastSignificantDataByte = UInt8(cpu.stackPointer & 0xFF)
            writeMemory(&cpu, leastSignificantDataByte, address)
            
            let mostSignificantDataByte = UInt8(cpu.stackPointer >> 8)
            writeMemory(&cpu, mostSignificantDataByte, address + 1)
        },
        /// ADD HL
        0x09: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x0A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = readMemory(cpu, cpu.registerBC.all)
        },
        /// DEC rr
        0x0B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.all &-= 1
        },
        /// INC r
        0x0C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerBC.lo)
            cpu.registerBC.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x0D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerBC.lo)
            cpu.registerBC.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x0E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
        },
        /// RRCA
        0x0F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
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
        0x10: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.programCounter += 1
        },
        /// LD rr 16 bit
        0x11: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerDE.all = value
        },
        /// LD (DE), A
        0x12: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = cpu.registerAF.hi
            writeMemory(&cpu, value, cpu.registerDE.all)
        },
        /// INC rr
        0x13: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.all &+= 1
        },
        /// INC r
        0x14: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerDE.hi)
            cpu.registerDE.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x15: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerDE.hi)
            cpu.registerDE.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x16: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
        },
        /// RLA
        0x17: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
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
        0x18: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let signedValue = Int16(Int8(bitPattern: value))
            let programCounter = Int16(bitPattern: cpu.programCounter)
            let address = programCounter + signedValue
            cpu.programCounter = UInt16(bitPattern: address)
        },
        /// ADD HL
        0x19: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x1A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerDE.all)
            cpu.registerAF.hi = value
        },
        /// DEC rr
        0x1B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.all &-= 1
        },
        /// INC r
        0x1C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerDE.lo)
            cpu.registerDE.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x1D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerDE.lo)
            cpu.registerDE.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x1E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
        },
        /// RRA
        0x1F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
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
        0x20: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            if !cpu.zeroFlag {
                return InstructionV2(cycles: 3) { cpu, readMemory, writeMemory in
                    let value = readMemory(cpu, cpu.programCounter)
                    cpu.programCounter += 1
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return InstructionV2(cycles: 2) { cpu, readMemory, writeMemory in
                    let _ = readMemory(cpu, cpu.programCounter)
                    cpu.programCounter += 1
                }
            }
        },
        /// LD HL rr 16 bit
        0x21: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerHL.all = value
        },
        /// LD (HL+), A
        0x22: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let address = cpu.registerHL.all
            writeMemory(&cpu, cpu.registerAF.hi, address)
            cpu.registerHL.all &+= 1
        },
        /// INC rr
        0x23: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.all &+= 1
        },
        /// INC r
        0x24: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerHL.hi)
            cpu.registerHL.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x25: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerHL.hi)
            cpu.registerHL.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x26: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
        },
        /// DAA
        0x27: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            //TODO: - Implement DAA Instruction
        },
        /// JR cc, e
        0x28: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            if cpu.zeroFlag {
                return InstructionV2(cycles: 3) { cpu, readMemory, writeMemory in
                    let value = readMemory(cpu, cpu.programCounter)
                    cpu.programCounter += 1
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return InstructionV2(cycles: 2) { cpu, readMemory, writeMemory in
                    let _ = readMemory(cpu, cpu.programCounter)
                    cpu.programCounter += 1
                }
            }
        },
        /// ADD HL
        0x29: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x2A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let address = cpu.registerHL.all
            cpu.registerAF.hi = readMemory(cpu, address)
            cpu.registerHL.all += 1
        },
        /// DEC rr
        0x2B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.all &-= 1
        },
        /// INC r
        0x2C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerHL.lo)
            cpu.registerHL.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x2D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerHL.lo)
            cpu.registerHL.lo = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x2E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
        },
        /// LDrn Load to 8 bit register r, the data n
        0x2F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
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
        0x30: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            if !cpu.carryFlag {
                return InstructionV2(cycles: 3) { cpu, readMemory, writeMemory in
                    let value = readMemory(cpu, cpu.programCounter)
                    cpu.programCounter += 1
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return InstructionV2(cycles: 2) { cpu, readMemory, writeMemory in
                    let _ = readMemory(cpu, cpu.programCounter)
                    cpu.programCounter += 1
                }
            }
        },
        /// LD rr 16 bit
        0x31: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.stackPointer = value
        },
        /// LD (HL-), A
        0x32: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let address = cpu.registerHL.all
            writeMemory(&cpu, cpu.registerAF.hi, address)
            cpu.registerHL.all &-= 1
        },
        /// INC rr
        0x33: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.stackPointer &+= 1
        },
        /// INC HL
        0x34: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let result = ALU.increment(readMemory(cpu, cpu.registerHL.all))
            writeMemory(&cpu, result.value, cpu.registerHL.all)
            cpu.updateFlag(result.flag)
        },
        /// DEC HL
        0x35: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(readMemory(cpu, cpu.registerHL.all))
            writeMemory(&cpu, result.value, cpu.registerHL.all)
            cpu.updateFlag(result.flag)
        },
        /// LD (HL)
        0x36: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// SCF
        0x37: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(true)
            )
            cpu.updateFlag(flag)
        },
        /// JR cc, e
        0x38: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            if cpu.carryFlag {
                return InstructionV2(cycles: 3) { cpu, readMemory, writeMemory in
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return InstructionV2(cycles: 2) { _, _, _ in }
            }
        },
        /// ADD HL
        0x39: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x3A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let address = cpu.registerHL.all
            cpu.registerAF.hi = readMemory(cpu, address)
            cpu.registerHL.all -= 1
        },
        /// DEC rr
        0x3B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.stackPointer &-= 1
        },
        /// INC r
        0x3C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.increment(cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x3D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.decrement(cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x3E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
        },
        /// CCF
        0x3F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
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
        0x40: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x41: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x42: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x43: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x44: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x45: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x46: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = readMemory(cpu, cpu.registerHL.all)
        },
        /// LDrr`
        0x47: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerAF.hi
        },
        /// LDrr`
        0x48: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.hi
        },
        /// LDrr`
        0x49: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo
        },
        /// LDrr`
        0x4A: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerDE.hi
        },
        /// LDrr`
        0x4B: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerDE.lo
        },
        /// LDrr`
        0x4C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerHL.hi
        },
        /// LDrr`
        0x4D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x4E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = readMemory(cpu, cpu.registerHL.all)
        },
        /// LDrr`
        0x4F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerAF.hi
        },
        // MARK: - 0x50
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x50: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x51: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x52: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x53: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x54: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x55: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x56: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = readMemory(cpu, cpu.registerHL.all)
        },
        /// LDrr`
        0x57: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerAF.hi
        },
        /// LDrr`
        0x58: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerBC.hi
        },
        /// LDrr`
        0x59: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerBC.lo
        },
        /// LDrr`
        0x5A: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.hi
        },
        /// LDrr`
        0x5B: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo
        },
        /// LDrr`
        0x5C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerHL.hi
        },
        /// LDrr`
        0x5D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x5E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = readMemory(cpu, cpu.registerHL.all)
        },
        /// LDrr`
        0x5F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerAF.hi
        },
        
        // MARK: - 0x60
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x60: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x61: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x62: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x63: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x64: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x65: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x66: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = readMemory(cpu, cpu.registerHL.all)
        },
        /// LDrr`
        0x67: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerAF.hi
        },
        /// LDrr`
        0x68: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerBC.hi
        },
        /// LDrr`
        0x69: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerBC.lo
        },
        /// LDrr`
        0x6A: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerDE.hi
        },
        /// LDrr`
        0x6B: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerDE.lo
        },
        /// LDrr`
        0x6C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.hi
        },
        /// LDrr`
        0x6D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x6E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = readMemory(cpu, cpu.registerHL.all)
        },
        /// LDrr`
        0x6F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerAF.hi
        },
        
        // MARK: - 0x70
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x70: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(&cpu, cpu.registerBC.hi, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x71: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(&cpu, cpu.registerBC.lo, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x72: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(&cpu, cpu.registerDE.hi, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x73: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(&cpu, cpu.registerDE.lo, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x74: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(&cpu, cpu.registerHL.hi, cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x75: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(&cpu, cpu.registerHL.lo, cpu.registerHL.all)
        },
        /// TODO: implement correct HALT instruction
        0x76: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.isHalted = true
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x77: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            writeMemory(&cpu, cpu.registerAF.hi, cpu.registerHL.all)
        },
        /// LDrr`
        0x78: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x79: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x7A: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x7B: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x7C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x7D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x7E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = readMemory(cpu, cpu.registerHL.all)
        },
        /// LDrr`
        0x7F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi
        },
        
        // MARK: - 0x80
        /// ADD r
        0x80: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x81: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x82: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x83: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x84: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x85: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x86: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let result = ALU.add(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x87: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x88: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x89: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8A: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8B: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC (HL)
        0x8E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let result = ALU.add(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerAF.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        
        // MARK: - 0x90
        /// SUB r
        0x90: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x91: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x92: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x93: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x94: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x95: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x96: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x97: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x98: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x99: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9A: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9B: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9C: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9D: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC HL
        0x9E: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let result = ALU.sub(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9F: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // MARK: - 0xA0
        /// AND r
        0xA0: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA1: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA2: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA3: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA4: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA5: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND HL
        0xA6: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let result = ALU.and(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA7: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xA8: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xA9: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAA: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAB: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAC: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAD: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR HL
        0xAE: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let result = ALU.xor(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAF: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        
        // MARK: - 0xB0
        /// OR r
        0xB0: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB1: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB2: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB3: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB4: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB5: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR HL
        0xB6: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let result = ALU.or(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB7: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        
        /// CP r
        0xB8: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xB9: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBA: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBB: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBC: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBD: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.updateFlag(result.flag)
        },
        /// CP HL
        0xBE: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBF: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.updateFlag(result.flag)
        },
        
        // MARK: - 0xC0
        /// RET CC
        0xC0: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            if !cpu.zeroFlag {
                return InstructionV2(cycles: 5) { cpu, readMemory, writeMemory in
                    let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return InstructionV2(cycles: 2) { _, _, _ in }
            }
        },
        /// POP rr
        0xC1: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerBC.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xC2: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            if !cpu.zeroFlag {
                return InstructionV2(cycles: 4) { cpu, readMemory, writeMemory in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return InstructionV2(cycles: 3) { _, _, _ in }
            }
        },
        /// JP nn
        0xC3: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.programCounter = address
        },
        /// CALL cc, nn
        0xC4: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            if !cpu.zeroFlag {
                return InstructionV2(cycles: 6) { cpu, readMemory, writeMemory in
                    
                    cpu.stackPointer -= 1
                    writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
                    cpu.stackPointer -= 1
                    writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return InstructionV2(cycles: 3) { _, _, _ in }
            }
        },
        /// PUSH rr
        0xC5: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, cpu.registerBC.hi, cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, cpu.registerBC.lo, cpu.stackPointer)
        },
        /// ADD n
        0xC6: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.add(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 00
        0xC7: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x0 | 0x0
        },
        /// RET CC
        0xC8: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            if cpu.zeroFlag {
                return InstructionV2(cycles: 5) { cpu, readMemory, writeMemory in
                    let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return InstructionV2(cycles: 2) { _, _, _ in }
            }
        },
        /// RET
        0xC9: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xCA: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            if cpu.zeroFlag {
                return InstructionV2(cycles: 4) { cpu, readMemory, writeMemory in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return InstructionV2(cycles: 3) { _, _, _ in }
            }
        },
        /// PREFIX
        0xCB: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let opcode = readMemory(cpu, cpu.programCounter)
//            print(String(format: "%llx %llx", opcode, cpu.programCounter))
            cpu.programCounter += 1
            if let instruction = prefixInstruction[opcode]?.build(&cpu, readMemory, writeMemory) {
                return instruction
//                return InstructionV2(cycles: instruction.cycles + 1, perform: instruction.perform)
            } else {
                fatalError("opcode : \(opcode) hasn't been implemented")
            }
        },
        /// CALL cc, nn
        0xCC: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            if cpu.zeroFlag {
                return InstructionV2(cycles: 6) { cpu, readMemory, writeMemory in
                    cpu.stackPointer -= 1
                    writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
                    cpu.stackPointer -= 1
                    writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return InstructionV2(cycles: 3) { _, _, _ in
                }
            }
        },
        /// CALLCALL nn
        0xCD: InstructionBuilderV2(cycles: 6) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            
            cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// ADC n
        0xCE: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.add(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 0x08
        0xCF: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x08
        },
        
        // MARK: - 0xD0
        /// RET CC
        0xD0: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            if !cpu.carryFlag {
                return InstructionV2(cycles: 5) { cpu, readMemory, writeMemory in
                    let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return InstructionV2(cycles: 2) { _, _, _ in }
            }
        },
        /// POP rr
        0xD1: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerDE.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xD2: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            if !cpu.carryFlag {
                return InstructionV2(cycles: 4) { cpu, readMemory, writeMemory in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return InstructionV2(cycles: 3) { _, _, _ in }
            }
        },
        /// CALL cc, nn
        0xD4: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            if !cpu.carryFlag {
                return InstructionV2(cycles: 6) { cpu, readMemory, writeMemory in
                    cpu.stackPointer -= 1
                    writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
                    cpu.stackPointer -= 1
                    writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return InstructionV2(cycles: 3) { _, _, _ in }
            }
        },
        /// PUSH rr
        0xD5: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, cpu.registerDE.hi, cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, cpu.registerDE.lo, cpu.stackPointer)
        },
        /// SUB n
        0xD6: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 10
        0xD7: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x10
        },
        /// RET CC
        0xD8: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            if cpu.carryFlag {
                return InstructionV2(cycles: 5) { cpu, readMemory, writeMemory in
                    let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return InstructionV2(cycles: 2) { _, _, _ in }
            }
        },
        /// RET CC
        0xD9: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.interruptMasterEnabled = true
        },
        /// JP cc, nn
        0xDA: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            if cpu.carryFlag {
                return InstructionV2(cycles: 4) { cpu, readMemory, writeMemory in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return InstructionV2(cycles: 3) { _, _, _ in }
            }
        },
        /// CALL cc, nn
        0xDC: InstructionBuilderV2 { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            if cpu.carryFlag {
                return InstructionV2(cycles: 6) { cpu, readMemory, writeMemory in
                    cpu.stackPointer -= 1
                    writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
                    cpu.stackPointer -= 1
                    writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return InstructionV2(cycles: 3) { _, _, _ in }
            }
        },
        /// SBC n
        0xDE: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.sub(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 18
        0xDF: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x18
        },
        
        // MARK: - 0xE0
        /// LDH (C), A
        0xE0: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            writeMemory(&cpu, cpu.registerAF.hi, address)
        },
        /// POP rr
        0xE1: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerHL.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// LDH (C), A
        0xE2: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let leastSignificantByte = cpu.registerBC.lo
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            writeMemory(&cpu, cpu.registerAF.hi, address)
        },
        /// PUSH rr
        0xE5: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, cpu.registerHL.hi, cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, cpu.registerHL.lo, cpu.stackPointer)
        },
        /// AND n
        0xE6: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.and(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 20
        0xE7: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x20
        },
        /// ADD SP
        0xE8: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
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
        0xE9: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.programCounter = cpu.registerHL.all
        },
        /// LD (nn), A
        0xEA: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            writeMemory(&cpu, cpu.registerAF.hi, address)
        },
        /// XOR n
        0xEE: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.xor(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 28
        0xEF: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x28
        },
        
        // MARK: - 0xF0
        /// LDH A, (n)
        0xF0: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            let value = readMemory(cpu, address)
            cpu.registerAF.hi = value
        },
        /// POP rr
        0xF1: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerAF.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte & 0xF0)
        },
        /// LDH  A, (C)
        0xF2: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let leastSignificantByte = cpu.registerBC.lo
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            cpu.registerAF.hi = readMemory(cpu, address)
        },
        /// DI
        0xF3: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.interruptMasterEnabled = false
        },
        /// PUSH rr
        0xF5: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, cpu.registerAF.hi, cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, cpu.registerAF.lo, cpu.stackPointer)
        },
        /// OR n
        0xF6: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.or(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlag(result.flag)
        },
        // RST n RST 30
        0xF7: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x30
        },
        /// LD HL, SP+e
        0xF8: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
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
        0xF9: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.stackPointer = cpu.registerHL.all
        },
        /// LD A, (nn)
        0xFA: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let leastSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let mostSignificantByte = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerAF.hi = readMemory(cpu, address)
        },
        /// DI
        0xFB: InstructionBuilderV2(cycles: 1) { cpu, readMemory, writeMemory in
            cpu.isInterruptMasterEnabledRequest = true
        },
        /// CP n
        0xFE: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.programCounter)
            cpu.programCounter += 1
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.updateFlag(result.flag)
        },
        // RST n RST 38
        0xFF: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
            cpu.stackPointer -= 1
            writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
            cpu.programCounter = 0x38
        },
    ]
    
    static let prefixInstruction: [UInt8: InstructionBuilderV2] = [
        // MARK: - 0x0
        /// RLC r
        0x00: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x01: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x02: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x03: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x04: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x05: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x06: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1) | bit7.toUInt8()
            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RLC r
        0x07: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x08: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x09: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x0A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x0B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x0C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x0D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x0E: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (bit0.toUInt8() << 7)
            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x0F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x10: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x11: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x12: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x13: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x14: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x15: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x16: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1) | carry
            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// RRC r
        0x17: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x18: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x19: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x1A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x1B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x1C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x1D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x1E: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (carry << 7)
            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// RR r
        0x1F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x20: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x21: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x22: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x23: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x24: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x25: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x26: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1)
            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlag(flag)
        },
        /// SLA r
        0x27: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x28: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x29: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x2A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x2B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x2C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x2D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x2E: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let bit7 = value.bit(7)
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (bit7.toUInt8() << 7)
            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRA r
        0x2F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x30: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x31: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x32: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x33: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x34: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x35: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x36: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let highNibbles = (value & 0xF0) >> 4
            let lowNibbles = (value & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            writeMemory(&cpu, swappedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            cpu.updateFlag(flag)
        },
        /// SWAP r
        0x37: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x38: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x39: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x3A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x3B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x3C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x3D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x3E: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let bit0 = value.bit(0)
            let shiftedValue = value >> 1
            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlag(flag)
        },
        /// SRL r
        0x3F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
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
        0x40: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x41: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x42: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x43: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x44: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x45: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x46: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x47: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x48: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x49: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x4E: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x50: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x51: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x52: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x53: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x54: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x55: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x56: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x57: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x58: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x59: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x5E: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x60: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x61: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x62: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x63: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x64: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x65: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x66: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x67: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x68: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x69: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x6E: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x70: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x71: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x72: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x73: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x74: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x75: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x76: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x77: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x78: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x79: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x7E: InstructionBuilderV2(cycles: 3) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlag(flag)
        },
        /// RES b, r
        0x80: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 0)
        },
        /// RES b, r
        0x81: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 0)
        },
        /// RES b, r
        0x82: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 0)
        },
        /// RES b, r
        0x83: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 0)
        },
        /// RES b, r
        0x84: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 0)
        },
        /// RES b, r
        0x85: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 0)
        },
        /// RES b, HL
        0x86: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 0)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0x87: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 0)
        },
        /// RES b, r
        0x88: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 1)
        },
        /// RES b, r
        0x89: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 1)
        },
        /// RES b, r
        0x8A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 1)
        },
        /// RES b, r
        0x8B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 1)
        },
        /// RES b, r
        0x8C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 1)
        },
        /// RES b, r
        0x8D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 1)
        },
        /// RES b, HL
        0x8E: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 1)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0x8F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 1)
        },
        /// RES b, r
        0x90: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 2)
        },
        /// RES b, r
        0x91: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 2)
        },
        /// RES b, r
        0x92: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 2)
        },
        /// RES b, r
        0x93: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 2)
        },
        /// RES b, r
        0x94: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 2)
        },
        /// RES b, r
        0x95: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 2)
        },
        /// RES b, HL
        0x96: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 2)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0x97: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 2)
        },
        /// RES b, r
        0x98: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 3)
        },
        /// RES b, r
        0x99: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 3)
        },
        /// RES b, r
        0x9A: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 3)
        },
        /// RES b, r
        0x9B: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 3)
        },
        /// RES b, r
        0x9C: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 3)
        },
        /// RES b, r
        0x9D: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 3)
        },
        /// RES b, HL
        0x9E: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 3)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0x9F: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 3)
        },
        /// RES b, r
        0xA0: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA1: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA2: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA3: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA4: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA5: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 4)
        },
        /// RES b, HL
        0xA6: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 4)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xA7: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA8: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 5)
        },
        /// RES b, r
        0xA9: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 5)
        },
        /// RES b, r
        0xAA: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 5)
        },
        /// RES b, r
        0xAB: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 5)
        },
        /// RES b, r
        0xAC: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 5)
        },
        /// RES b, r
        0xAD: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 5)
        },
        /// RES b, HL
        0xAE: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 5)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xAF: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 5)
        },
        /// RES b, r
        0xB0: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB1: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB2: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB3: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB4: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB5: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 6)
        },
        /// RES b, HL
        0xB6: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 6)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xB7: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB8: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 7)
        },
        /// RES b, r
        0xB9: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 7)
        },
        /// RES b, r
        0xBA: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 7)
        },
        /// RES b, r
        0xBB: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 7)
        },
        /// RES b, r
        0xBC: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 7)
        },
        /// RES b, r
        0xBD: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 7)
        },
        /// RES b, HL
        0xBE: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 7)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xBF: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 7)
        },
        /// RES b, r
        0xC0: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 0)
        },
        /// RES b, r
        0xC1: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 0)
        },
        /// RES b, r
        0xC2: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 0)
        },
        /// RES b, r
        0xC3: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 0)
        },
        /// RES b, r
        0xC4: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 0)
        },
        /// RES b, r
        0xC5: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 0)
        },
        /// RES b, HL
        0xC6: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 0)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xC7: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 0)
        },
        /// RES b, r
        0xC8: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 1)
        },
        /// RES b, r
        0xC9: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 1)
        },
        /// RES b, r
        0xCA: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 1)
        },
        /// RES b, r
        0xCB: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 1)
        },
        /// RES b, r
        0xCC: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 1)
        },
        /// RES b, r
        0xCD: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 1)
        },
        /// RES b, HL
        0xCE: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 1)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xCF: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 1)
        },
        /// RES b, r
        0xD0: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 2)
        },
        /// RES b, r
        0xD1: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 2)
        },
        /// RES b, r
        0xD2: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 2)
        },
        /// RES b, r
        0xD3: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 2)
        },
        /// RES b, r
        0xD4: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 2)
        },
        /// RES b, r
        0xD5: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 2)
        },
        /// RES b, HL
        0xD6: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 2)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xD7: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 2)
        },
        /// RES b, r
        0xD8: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 3)
        },
        /// RES b, r
        0xD9: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 3)
        },
        /// RES b, r
        0xDA: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 3)
        },
        /// RES b, r
        0xDB: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 3)
        },
        /// RES b, r
        0xDC: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 3)
        },
        /// RES b, r
        0xDD: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 3)
        },
        /// RES b, HL
        0xDE: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 3)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xDF: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 3)
        },
        /// RES b, r
        0xE0: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 4)
        },
        /// RES b, r
        0xE1: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 4)
        },
        /// RES b, r
        0xE2: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 4)
        },
        /// RES b, r
        0xE3: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 4)
        },
        /// RES b, r
        0xE4: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 4)
        },
        /// RES b, r
        0xE5: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 4)
        },
        /// RES b, HL
        0xE6: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 4)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xE7: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 4)
        },
        /// RES b, r
        0xE8: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 5)
        },
        /// RES b, r
        0xE9: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 5)
        },
        /// RES b, r
        0xEA: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 5)
        },
        /// RES b, r
        0xEB: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 5)
        },
        /// RES b, r
        0xEC: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 5)
        },
        /// RES b, r
        0xED: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 5)
        },
        /// RES b, HL
        0xEE: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 5)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xEF: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 5)
        },
        /// RES b, r
        0xF0: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 6)
        },
        /// RES b, r
        0xF1: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 6)
        },
        /// RES b, r
        0xF2: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 6)
        },
        /// RES b, r
        0xF3: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 6)
        },
        /// RES b, r
        0xF4: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 6)
        },
        /// RES b, r
        0xF5: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 6)
        },
        /// RES b, HL
        0xF6: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 6)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xF7: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 6)
        },
        /// RES b, r
        0xF8: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 7)
        },
        /// RES b, r
        0xF9: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 7)
        },
        /// RES b, r
        0xFA: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 7)
        },
        /// RES b, r
        0xFB: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 7)
        },
        /// RES b, r
        0xFC: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 7)
        },
        /// RES b, r
        0xFD: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 7)
        },
        /// RES b, HL
        0xFE: InstructionBuilderV2(cycles: 4) { cpu, readMemory, writeMemory in
            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 7)
            writeMemory(&cpu, value, cpu.registerHL.all)
        },
        /// RES b, r
        0xFF: InstructionBuilderV2(cycles: 2) { cpu, readMemory, writeMemory in
            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 7)
        },
    ]
}
