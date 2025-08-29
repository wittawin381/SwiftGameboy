//
//  InstructionV4.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 10/9/2568 BE.
//

import Foundation

//public struct InstructionBuilderV4V4<Handler: ReadWriteHandler & ~Copyable> {
//    /// Machine cyle : 1 Machine cycle = 4 clock cycles
//    public let build: (inout CPU, inout Handler) -> InstructionV4<Handler>
//
//    public init(cycles: Int, perform: @escaping (inout CPU, inout Handler) -> Void) {
//        self.build = { _, _ in
//            InstructionV4(cycles: cycles, perform: perform)
//        }
//    }
//
//    public init(perform: @escaping (inout CPU, inout Handler) -> InstructionV4<Handler>) {
//        self.build = { cpu, readWriteHandler in
//            perform(&cpu, &readWriteHandler)
//        }
//    }
//
//}

//public struct InstructionV4<Handler: ReadWriteHandler & ~Copyable> {
//    public let cycles: Int
//    public let perform: (inout CPU, inout Handler) -> Void
//
//    public init(cycles: Int, perform: @escaping (inout CPU, inout Handler) -> Void) {
//        self.cycles = cycles
//        self.perform = perform
//    }
//}

//public typealias MemoryReadHandlerV4 = (borrowing CPUContext, UInt16) -> UInt8
//public typealias MemoryWriteHandlerV4 = (inout CPUContext, UInt8, UInt16) -> Void

public struct InstructionBuilderV4 {
    /// Machine cyle : 1 Machine cycle = 4 clock cycles
    public let build: (inout GB) -> InstructionV4
    
    public init(cycles: Int, perform: @escaping (inout GB) -> Void) {
        self.build = { _ in
            InstructionV4(cycles: cycles, perform: perform)
        }
    }
    
    public init(perform: @escaping (inout GB) -> InstructionV4) {
        self.build = { context in
            perform(&context)
        }
    }
}

public struct InstructionV4 {
    public let cycles: Int
    public let perform: (inout GB) -> Void
    
    public init(cycles: Int, perform: @escaping (inout GB) -> Void) {
        self.cycles = cycles
        self.perform = perform
    }
}

extension InstructionBuilderV4 {
    static let instructions: [UInt8: InstructionBuilderV4] = [
        // MARK: - 0x00
        /// NOP
        0x00: InstructionBuilderV4(cycles: 1) { _ in
            /// Do Nothing
        },
        /// LD rr 16 bit
        0x01: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            
            
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            context.cpu.registerBC.all = value
        },
        /// LD (BC), A
        0x02: InstructionBuilderV4(cycles: 2) { context in
            let value = context.cpu.registerAF.hi
            
            context.write(value, to: context.cpu.registerBC.all)
        },
        /// INC rr
        0x03: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.all &+= 1
        },
        /// INC r
        0x04: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.increment(context.cpu.registerBC.hi)
            context.cpu.registerBC.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x05: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.decrement(context.cpu.registerBC.hi)
            context.cpu.registerBC.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x06: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
        },
        /// RLCA
        0x07: InstructionBuilderV4(cycles: 1) { context in
            let bit7 = context.cpu.registerAF.hi.bit(7)
            let shiftedValue = (context.cpu.registerAF.hi << 1) | bit7.toUInt8()
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// LD (nn), SP
        0x08: InstructionBuilderV4(cycles: 5) { context in
            let leastSignificantAddressByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantAddressByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let address = (UInt16(mostSignificantAddressByte) << 8) | UInt16(leastSignificantAddressByte)
            
            let leastSignificantDataByte = UInt8(context.cpu.stackPointer & 0xFF)
            context.write(leastSignificantDataByte, to: address)
            
            let mostSignificantDataByte = UInt8(context.cpu.stackPointer >> 8)
            context.write(mostSignificantDataByte, to: address + 1)
        },
        /// ADD HL
        0x09: InstructionBuilderV4(cycles: 2) { context in
            let result = ALU.add16(context.cpu.registerHL.all, context.cpu.registerBC.all, carryBit: 11)
            context.cpu.registerHL.all = result.value
            context.cpu.updateFlag(
                ALU.Flag(
                    zero: .noneAffected,
                    subtract: result.flag.subtract,
                    halfCarry: result.flag.halfCarry,
                    carry: result.flag.carry
                )
            )
        },
        /// LD A, (BC) Load to the 8-bit A register, data from the absolute address specified by the 16-bit register BC.
        0x0A: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.read(context.cpu.registerBC.all)
        },
        /// DEC rr
        0x0B: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.all &-= 1
        },
        /// INC r
        0x0C: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.increment(context.cpu.registerBC.lo)
            context.cpu.registerBC.lo = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x0D: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.decrement(context.cpu.registerBC.lo)
            context.cpu.registerBC.lo = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x0E: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
        },
        /// RRCA
        0x0F: InstructionBuilderV4(cycles: 1) { context in
            let bit0 = context.cpu.registerAF.hi.bit(0)
            let shiftedValue = (bit0.toUInt8() << 7) | (context.cpu.registerAF.hi >> 1)
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        
        // MARK: - 0x01
        /// LD rr 16 bit
        /// TODO: - correctly implement STOP
        0x10: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.programCounter += 1
        },
        /// LD rr 16 bit
        0x11: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte: UInt8 = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte: UInt8 = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            context.cpu.registerDE.all = value
        },
        /// LD (DE), A
        0x12: InstructionBuilderV4(cycles: 2) { context in
            let value = context.cpu.registerAF.hi
            context.write(value, to: context.cpu.registerDE.all)
        },
        /// INC rr
        0x13: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.all &+= 1
        },
        /// INC r
        0x14: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.increment(context.cpu.registerDE.hi)
            context.cpu.registerDE.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x15: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.decrement(context.cpu.registerDE.hi)
            context.cpu.registerDE.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x16: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
        },
        /// RLA
        0x17: InstructionBuilderV4(cycles: 1) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit7 = context.cpu.registerAF.hi.bit(7)
            let shiftedValue = (context.cpu.registerAF.hi << 1) | carry
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// JR e
        0x18: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let signedValue = Int16(Int8(bitPattern: value))
            let programCounter = Int16(bitPattern: context.cpu.programCounter)
            let address = programCounter + signedValue
            context.cpu.programCounter = UInt16(bitPattern: address)
        },
        /// ADD HL
        0x19: InstructionBuilderV4(cycles: 2) { context in
            let result = ALU.add16(context.cpu.registerHL.all, context.cpu.registerDE.all, carryBit: 11)
            context.cpu.registerHL.all = result.value
            context.cpu.updateFlag(
                ALU.Flag(
                    zero: .noneAffected,
                    subtract: result.flag.subtract,
                    halfCarry: result.flag.halfCarry,
                    carry: result.flag.carry
                )
            )
        },
        /// LD A, (BC) Load to the 8-bit A register, data from the absolute address specified by the 16-bit register BC.
        0x1A: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.registerDE.all)
            context.cpu.registerAF.hi = value
        },
        /// DEC rr
        0x1B: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.all &-= 1
        },
        /// INC r
        0x1C: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.increment(context.cpu.registerDE.lo)
            context.cpu.registerDE.lo = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x1D: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.decrement(context.cpu.registerDE.lo)
            context.cpu.registerDE.lo = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x1E: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
        },
        /// RRA
        0x1F: InstructionBuilderV4(cycles: 1) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit0 = context.cpu.registerAF.hi.bit(0)
            let shiftedValue = (context.cpu.registerAF.hi >> 1) | (carry << 7)
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        
        // MARK: - 0x02
        /// JR cc, e
        0x20: InstructionBuilderV4 { context in
            if !context.cpu.zeroFlag {
                return InstructionV4(cycles: 3) { context in
                    let value = context.read(context.cpu.programCounter)
                    context.cpu.programCounter += 1
                    let signedValue = Int8(bitPattern: value)
                    context.cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return InstructionV4(cycles: 2) { context in
                    let _ = context.read(context.cpu.programCounter)
                    context.cpu.programCounter += 1
                }
            }
        },
        /// LD HL rr 16 bit
        0x21: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte: UInt8 = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte: UInt8 = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            context.cpu.registerHL.all = value
        },
        /// LD (HL+), A
        0x22: InstructionBuilderV4(cycles: 2) { context in
            let address = context.cpu.registerHL.all
            context.write(context.cpu.registerAF.hi, to: address)
            context.cpu.registerHL.all &+= 1
        },
        /// INC rr
        0x23: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.all &+= 1
        },
        /// INC r
        0x24: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.increment(context.cpu.registerHL.hi)
            context.cpu.registerHL.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x25: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.decrement(context.cpu.registerHL.hi)
            context.cpu.registerHL.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x26: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
        },
        /// DAA
        0x27: InstructionBuilderV4(cycles: 1) { context in
            //TODO: - Implement DAA Instruction
        },
        /// JR cc, e
        0x28: InstructionBuilderV4 { context in
            if context.cpu.zeroFlag {
                return InstructionV4(cycles: 3) { context in
                    let value = context.read(context.cpu.programCounter)
                    context.cpu.programCounter += 1
                    let signedValue = Int8(bitPattern: value)
                    context.cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return InstructionV4(cycles: 2) { context in
                    let _ = context.read(context.cpu.programCounter)
                    context.cpu.programCounter += 1
                }
            }
        },
        /// ADD HL
        0x29: InstructionBuilderV4(cycles: 2) { context in
            let result = ALU.add16(context.cpu.registerHL.all, context.cpu.registerHL.all, carryBit: 11)
            context.cpu.registerHL.all = result.value
            context.cpu.updateFlag(
                ALU.Flag(
                    zero: .noneAffected,
                    subtract: result.flag.subtract,
                    halfCarry: result.flag.halfCarry,
                    carry: result.flag.carry
                )
            )
        },
        /// LD A, (HL+)
        0x2A: InstructionBuilderV4(cycles: 2) { context in
            let address = context.cpu.registerHL.all
            context.cpu.registerAF.hi = context.read(address)
            context.cpu.registerHL.all += 1
        },
        /// DEC rr
        0x2B: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.all &-= 1
        },
        /// INC r
        0x2C: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.increment(context.cpu.registerHL.lo)
            context.cpu.registerHL.lo = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x2D: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.decrement(context.cpu.registerHL.lo)
            context.cpu.registerHL.lo = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x2E: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
        },
        /// LDrn Load to 8 bit register r, the data n
        0x2F: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerAF.hi = ~context.cpu.registerAF.hi
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        
        // MARK: - 0x03
        /// JR cc, e
        0x30: InstructionBuilderV4 { context in
            if !context.cpu.carryFlag {
                return InstructionV4(cycles: 3) { context in
                    let value = context.read(context.cpu.programCounter)
                    context.cpu.programCounter += 1
                    let signedValue = Int8(bitPattern: value)
                    context.cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return InstructionV4(cycles: 2) { context in
                    let _ = context.read(context.cpu.programCounter)
                    context.cpu.programCounter += 1
                }
            }
        },
        /// LD rr 16 bit
        0x31: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte: UInt8 = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte: UInt8 = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            context.cpu.stackPointer = value
        },
        /// LD (HL-), A
        0x32: InstructionBuilderV4(cycles: 2) { context in
            let address = context.cpu.registerHL.all
            context.write(context.cpu.registerAF.hi, to: address)
            context.cpu.registerHL.all &-= 1
        },
        /// INC rr
        0x33: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.stackPointer &+= 1
        },
        /// INC HL
        0x34: InstructionBuilderV4(cycles: 3) { context in
            let result = ALU.increment(context.read(context.cpu.registerHL.all))
            context.write(result.value, to: context.cpu.registerHL.all)
            context.cpu.updateFlag(result.flag)
        },
        /// DEC HL
        0x35: InstructionBuilderV4(cycles: 3) { context in
            let result = ALU.decrement(context.read(context.cpu.registerHL.all))
            context.write(result.value, to: context.cpu.registerHL.all)
            context.cpu.updateFlag(result.flag)
        },
        /// LD (HL)
        0x36: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// SCF
        0x37: InstructionBuilderV4(cycles: 1) { context in
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(true)
            )
            context.cpu.updateFlag(flag)
        },
        /// JR cc, e
        0x38: InstructionBuilderV4 { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            if context.cpu.carryFlag {
                return InstructionV4(cycles: 3) { context in
                    let signedValue = Int8(bitPattern: value)
                    context.cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return InstructionV4(cycles: 2) { _ in }
            }
        },
        /// ADD HL
        0x39: InstructionBuilderV4(cycles: 2) { context in
            let result = ALU.add16(context.cpu.registerHL.all, context.cpu.stackPointer, carryBit: 11)
            context.cpu.registerHL.all = result.value
            context.cpu.updateFlag(
                ALU.Flag(
                    zero: .noneAffected,
                    subtract: result.flag.subtract,
                    halfCarry: result.flag.halfCarry,
                    carry: result.flag.carry
                )
            )
        },
        /// LD A, (HL-)
        0x3A: InstructionBuilderV4(cycles: 2) { context in
            let address = context.cpu.registerHL.all
            context.cpu.registerAF.hi = context.read(address)
            context.cpu.registerHL.all -= 1
        },
        /// DEC rr
        0x3B: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.stackPointer &-= 1
        },
        /// INC r
        0x3C: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.increment(context.cpu.registerAF.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// DEC r
        0x3D: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.decrement(context.cpu.registerAF.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x3E: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
        },
        /// CCF
        0x3F: InstructionBuilderV4(cycles: 1) { context in
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(!context.cpu.carryFlag)
            )
            context.cpu.updateFlag(flag)
        },
        
        // MARK: - 0x40
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x40: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi
        },
        /// LDrr`
        0x41: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.lo
        },
        /// LDrr`
        0x42: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.hi = context.cpu.registerDE.hi
        },
        /// LDrr`
        0x43: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.hi = context.cpu.registerDE.lo
        },
        /// LDrr`
        0x44: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.hi = context.cpu.registerHL.hi
        },
        /// LDrr`
        0x45: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.hi = context.cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x46: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.read(context.cpu.registerHL.all)
        },
        /// LDrr`
        0x47: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.hi = context.cpu.registerAF.hi
        },
        /// LDrr`
        0x48: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.hi
        },
        /// LDrr`
        0x49: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo
        },
        /// LDrr`
        0x4A: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.lo = context.cpu.registerDE.hi
        },
        /// LDrr`
        0x4B: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.lo = context.cpu.registerDE.lo
        },
        /// LDrr`
        0x4C: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.lo = context.cpu.registerHL.hi
        },
        /// LDrr`
        0x4D: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.lo = context.cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x4E: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.read(context.cpu.registerHL.all)
        },
        /// LDrr`
        0x4F: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerBC.lo = context.cpu.registerAF.hi
        },
        // MARK: - 0x50
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x50: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.hi = context.cpu.registerBC.hi
        },
        /// LDrr`
        0x51: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.hi = context.cpu.registerBC.lo
        },
        /// LDrr`
        0x52: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi
        },
        /// LDrr`
        0x53: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.lo
        },
        /// LDrr`
        0x54: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.hi = context.cpu.registerHL.hi
        },
        /// LDrr`
        0x55: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.hi = context.cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x56: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.read(context.cpu.registerHL.all)
        },
        /// LDrr`
        0x57: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.hi = context.cpu.registerAF.hi
        },
        /// LDrr`
        0x58: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.lo = context.cpu.registerBC.hi
        },
        /// LDrr`
        0x59: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.lo = context.cpu.registerBC.lo
        },
        /// LDrr`
        0x5A: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.hi
        },
        /// LDrr`
        0x5B: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo
        },
        /// LDrr`
        0x5C: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.lo = context.cpu.registerHL.hi
        },
        /// LDrr`
        0x5D: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.lo = context.cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x5E: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.read(context.cpu.registerHL.all)
        },
        /// LDrr`
        0x5F: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerDE.lo = context.cpu.registerAF.hi
        },
        
        // MARK: - 0x60
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x60: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.hi = context.cpu.registerBC.hi
        },
        /// LDrr`
        0x61: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.hi = context.cpu.registerBC.lo
        },
        /// LDrr`
        0x62: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.hi = context.cpu.registerDE.hi
        },
        /// LDrr`
        0x63: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.hi = context.cpu.registerDE.lo
        },
        /// LDrr`
        0x64: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi
        },
        /// LDrr`
        0x65: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x66: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.read(context.cpu.registerHL.all)
        },
        /// LDrr`
        0x67: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.hi = context.cpu.registerAF.hi
        },
        /// LDrr`
        0x68: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.lo = context.cpu.registerBC.hi
        },
        /// LDrr`
        0x69: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.lo = context.cpu.registerBC.lo
        },
        /// LDrr`
        0x6A: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.lo = context.cpu.registerDE.hi
        },
        /// LDrr`
        0x6B: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.lo = context.cpu.registerDE.lo
        },
        /// LDrr`
        0x6C: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.hi
        },
        /// LDrr`
        0x6D: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x6E: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.read(context.cpu.registerHL.all)
        },
        /// LDrr`
        0x6F: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerHL.lo = context.cpu.registerAF.hi
        },
        
        // MARK: - 0x70
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x70: InstructionBuilderV4(cycles: 2) { context in
            context.write(context.cpu.registerBC.hi, to: context.cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x71: InstructionBuilderV4(cycles: 2) { context in
            context.write(context.cpu.registerBC.lo, to: context.cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x72: InstructionBuilderV4(cycles: 2) { context in
            context.write(context.cpu.registerDE.hi, to: context.cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x73: InstructionBuilderV4(cycles: 2) { context in
            context.write(context.cpu.registerDE.lo, to: context.cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x74: InstructionBuilderV4(cycles: 2) { context in
            context.write(context.cpu.registerHL.hi, to: context.cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x75: InstructionBuilderV4(cycles: 2) { context in
            context.write(context.cpu.registerHL.lo, to: context.cpu.registerHL.all)
        },
        /// TODO: implement correct HALT instruction
        0x76: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.isHalted = true
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x77: InstructionBuilderV4(cycles: 2) { context in
            context.write(context.cpu.registerAF.hi, to: context.cpu.registerHL.all)
        },
        /// LDrr`
        0x78: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerAF.hi = context.cpu.registerBC.hi
        },
        /// LDrr`
        0x79: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerAF.hi = context.cpu.registerBC.lo
        },
        /// LDrr`
        0x7A: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerAF.hi = context.cpu.registerDE.hi
        },
        /// LDrr`
        0x7B: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerAF.hi = context.cpu.registerDE.lo
        },
        /// LDrr`
        0x7C: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerAF.hi = context.cpu.registerHL.hi
        },
        /// LDrr`
        0x7D: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerAF.hi = context.cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x7E: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.read(context.cpu.registerHL.all)
        },
        /// LDrr`
        0x7F: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi
        },
        
        // MARK: - 0x80
        /// ADD r
        0x80: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerBC.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x81: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerBC.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x82: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerDE.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x83: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerDE.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x84: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerHL.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x85: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerHL.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x86: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.registerHL.all)
            let result = ALU.add(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADD r
        0x87: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerAF.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x88: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerBC.hi, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x89: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerBC.lo, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8A: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerDE.hi, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8B: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerDE.lo, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8C: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerHL.hi, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8D: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerHL.lo, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADC (HL)
        0x8E: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.registerHL.all)
            let result = ALU.add(context.cpu.registerAF.hi, value, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// ADC r
        0x8F: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.add(context.cpu.registerAF.hi, context.cpu.registerAF.hi, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        
        // MARK: - 0x90
        /// SUB r
        0x90: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerBC.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x91: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerBC.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x92: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerDE.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x93: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerDE.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x94: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerHL.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x95: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerHL.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x96: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.registerHL.all)
            let result = ALU.sub(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SUB r
        0x97: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerAF.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x98: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerBC.hi, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x99: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerBC.lo, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9A: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerDE.hi, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9B: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerDE.lo, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9C: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerHL.hi, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9D: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerHL.lo, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SBC HL
        0x9E: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.registerHL.all)
            let result = ALU.sub(context.cpu.registerAF.hi, value, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// SBC r
        0x9F: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerAF.hi, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        // MARK: - 0xA0
        /// AND r
        0xA0: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.and(context.cpu.registerAF.hi, context.cpu.registerBC.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA1: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.and(context.cpu.registerAF.hi, context.cpu.registerBC.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA2: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.and(context.cpu.registerAF.hi, context.cpu.registerDE.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA3: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.and(context.cpu.registerAF.hi, context.cpu.registerDE.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA4: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.and(context.cpu.registerAF.hi, context.cpu.registerHL.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA5: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.and(context.cpu.registerAF.hi, context.cpu.registerHL.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// AND HL
        0xA6: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.registerHL.all)
            let result = ALU.and(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// AND r
        0xA7: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.and(context.cpu.registerAF.hi, context.cpu.registerAF.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xA8: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.xor(context.cpu.registerAF.hi, context.cpu.registerBC.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xA9: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.xor(context.cpu.registerAF.hi, context.cpu.registerBC.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAA: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.xor(context.cpu.registerAF.hi, context.cpu.registerDE.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAB: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.xor(context.cpu.registerAF.hi, context.cpu.registerDE.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAC: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.xor(context.cpu.registerAF.hi, context.cpu.registerHL.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAD: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.xor(context.cpu.registerAF.hi, context.cpu.registerHL.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// XOR HL
        0xAE: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.registerHL.all)
            let result = ALU.xor(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// XOR r
        0xAF: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.xor(context.cpu.registerAF.hi, context.cpu.registerAF.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        
        // MARK: - 0xB0
        /// OR r
        0xB0: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.or(context.cpu.registerAF.hi, context.cpu.registerBC.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB1: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.or(context.cpu.registerAF.hi, context.cpu.registerBC.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB2: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.or(context.cpu.registerAF.hi, context.cpu.registerDE.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB3: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.or(context.cpu.registerAF.hi, context.cpu.registerDE.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB4: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.or(context.cpu.registerAF.hi, context.cpu.registerHL.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB5: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.or(context.cpu.registerAF.hi, context.cpu.registerHL.lo)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// OR HL
        0xB6: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.registerHL.all)
            let result = ALU.or(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        /// OR r
        0xB7: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.or(context.cpu.registerAF.hi, context.cpu.registerAF.hi)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        
        /// CP r
        0xB8: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerBC.hi)
            context.cpu.updateFlag(result.flag)
        },
        /// CP r
        0xB9: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerBC.lo)
            context.cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBA: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerDE.hi)
            context.cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBB: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerDE.lo)
            context.cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBC: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerHL.hi)
            context.cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBD: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerHL.lo)
            context.cpu.updateFlag(result.flag)
        },
        /// CP HL
        0xBE: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.registerHL.all)
            let result = ALU.sub(context.cpu.registerAF.hi, value)
            context.cpu.updateFlag(result.flag)
        },
        /// CP r
        0xBF: InstructionBuilderV4(cycles: 1) { context in
            let result = ALU.sub(context.cpu.registerAF.hi, context.cpu.registerAF.hi)
            context.cpu.updateFlag(result.flag)
        },
        
        // MARK: - 0xC0
        /// RET CC
        0xC0: InstructionBuilderV4 { context in
            if !context.cpu.zeroFlag {
                return InstructionV4(cycles: 5) { context in
                    let leastSignificantByte = context.read(context.cpu.stackPointer)
                    context.cpu.stackPointer += 1
                    let mostSignificantByte = context.read(context.cpu.stackPointer)
                    context.cpu.stackPointer += 1
                    context.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return InstructionV4(cycles: 2) { _ in }
            }
        },
        /// POP rr
        0xC1: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            let mostSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            context.cpu.registerBC.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xC2: InstructionBuilderV4 { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            if !context.cpu.zeroFlag {
                return InstructionV4(cycles: 4) { context in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    context.cpu.programCounter = address
                }
            } else {
                return InstructionV4(cycles: 3) { _ in }
            }
        },
        /// JP nn
        0xC3: InstructionBuilderV4(cycles: 4) { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            context.cpu.programCounter = address
        },
        /// CALL cc, nn
        0xC4: InstructionBuilderV4 { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            if !context.cpu.zeroFlag {
                return InstructionV4(cycles: 6) { context in
                    
                    context.cpu.stackPointer -= 1
                    context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
                    context.cpu.stackPointer -= 1
                    context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    context.cpu.programCounter = address
                }
            } else {
                return InstructionV4(cycles: 3) { _ in }
            }
        },
        /// PUSH rr
        0xC5: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(context.cpu.registerBC.hi, to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(context.cpu.registerBC.lo, to: context.cpu.stackPointer)
        },
        /// ADD n
        0xC6: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let result = ALU.add(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        // RST n RST 00
        0xC7: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
            context.cpu.programCounter = 0x0 | 0x0
        },
        /// RET CC
        0xC8: InstructionBuilderV4 { context in
            if context.cpu.zeroFlag {
                return InstructionV4(cycles: 5) { context in
                    let leastSignificantByte = context.read(context.cpu.stackPointer)
                    context.cpu.stackPointer += 1
                    let mostSignificantByte = context.read(context.cpu.stackPointer)
                    context.cpu.stackPointer += 1
                    context.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return InstructionV4(cycles: 2) { _ in }
            }
        },
        /// RET
        0xC9: InstructionBuilderV4(cycles: 4) { context in
            let leastSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            let mostSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            context.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xCA: InstructionBuilderV4 { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            if context.cpu.zeroFlag {
                return InstructionV4(cycles: 4) { context in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    context.cpu.programCounter = address
                }
            } else {
                return InstructionV4(cycles: 3) { _ in }
            }
        },
        /// PREFIX
        0xCB: InstructionBuilderV4 { context in
            let opcode = context.read(context.cpu.programCounter)
//            print(String(format: "%llx %llx", opcode, context.cpu.programCounter))
            context.cpu.programCounter += 1
            if let instruction = prefixInstruction[opcode]?.build(&context) {
                return instruction
//                return InstructionV4(cycles: instruction.cycles + 1, perform: instruction.perform)
            } else {
                fatalError("opcode : \(opcode) hasn't been implemented")
            }
        },
        /// CALL cc, nn
        0xCC: InstructionBuilderV4 { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            if context.cpu.zeroFlag {
                return InstructionV4(cycles: 6) { context in
                    context.cpu.stackPointer -= 1
                    context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
                    context.cpu.stackPointer -= 1
                    context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    context.cpu.programCounter = address
                }
            } else {
                return InstructionV4(cycles: 3) { _ in
                }
            }
        },
        /// CALLCALL nn
        0xCD: InstructionBuilderV4(cycles: 6) { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
            
            context.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// ADC n
        0xCE: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let result = ALU.add(context.cpu.registerAF.hi, value, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        // RST n RST 0x08
        0xCF: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
            context.cpu.programCounter = 0x08
        },
        
        // MARK: - 0xD0
        /// RET CC
        0xD0: InstructionBuilderV4 { context in
            if !context.cpu.carryFlag {
                return InstructionV4(cycles: 5) { context in
                    let leastSignificantByte = context.read(context.cpu.stackPointer)
                    context.cpu.stackPointer += 1
                    let mostSignificantByte = context.read(context.cpu.stackPointer)
                    context.cpu.stackPointer += 1
                    context.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return InstructionV4(cycles: 2) { _ in }
            }
        },
        /// POP rr
        0xD1: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            let mostSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            context.cpu.registerDE.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xD2: InstructionBuilderV4 { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            if !context.cpu.carryFlag {
                return InstructionV4(cycles: 4) { context in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    context.cpu.programCounter = address
                }
            } else {
                return InstructionV4(cycles: 3) { _ in }
            }
        },
        /// CALL cc, nn
        0xD4: InstructionBuilderV4 { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            if !context.cpu.carryFlag {
                return InstructionV4(cycles: 6) { context in
                    context.cpu.stackPointer -= 1
                    context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
                    context.cpu.stackPointer -= 1
                    context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    context.cpu.programCounter = address
                }
            } else {
                return InstructionV4(cycles: 3) { _ in }
            }
        },
        /// PUSH rr
        0xD5: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(context.cpu.registerDE.hi, to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(context.cpu.registerDE.lo, to: context.cpu.stackPointer)
        },
        /// SUB n
        0xD6: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let result = ALU.sub(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        // RST n RST 10
        0xD7: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
            context.cpu.programCounter = 0x10
        },
        /// RET CC
        0xD8: InstructionBuilderV4 { context in
            if context.cpu.carryFlag {
                return InstructionV4(cycles: 5) { context in
                    let leastSignificantByte = context.read(context.cpu.stackPointer)
                    context.cpu.stackPointer += 1
                    let mostSignificantByte = context.read(context.cpu.stackPointer)
                    context.cpu.stackPointer += 1
                    context.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return InstructionV4(cycles: 2) { _ in }
            }
        },
        /// RET CC
        0xD9: InstructionBuilderV4(cycles: 4) { context in
            let leastSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            let mostSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            context.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            context.cpu.interruptMasterEnabled = true
        },
        /// JP cc, nn
        0xDA: InstructionBuilderV4 { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            if context.cpu.carryFlag {
                return InstructionV4(cycles: 4) { context in
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    context.cpu.programCounter = address
                }
            } else {
                return InstructionV4(cycles: 3) { _ in }
            }
        },
        /// CALL cc, nn
        0xDC: InstructionBuilderV4 { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            if context.cpu.carryFlag {
                return InstructionV4(cycles: 6) { context in
                    context.cpu.stackPointer -= 1
                    context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
                    context.cpu.stackPointer -= 1
                    context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
                    
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    context.cpu.programCounter = address
                }
            } else {
                return InstructionV4(cycles: 3) { _ in }
            }
        },
        /// SBC n
        0xDE: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let result = ALU.sub(context.cpu.registerAF.hi, value, carry: context.cpu.carryFlag)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        // RST n RST 18
        0xDF: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
            context.cpu.programCounter = 0x18
        },
        
        // MARK: - 0xE0
        /// LDH (C), A
        0xE0: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            context.write(context.cpu.registerAF.hi, to: address)
        },
        /// POP rr
        0xE1: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            let mostSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            context.cpu.registerHL.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// LDH (C), A
        0xE2: InstructionBuilderV4(cycles: 2) { context in
            let leastSignificantByte = context.cpu.registerBC.lo
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            context.write(context.cpu.registerAF.hi, to: address)
        },
        /// PUSH rr
        0xE5: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(context.cpu.registerHL.hi, to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(context.cpu.registerHL.lo, to: context.cpu.stackPointer)
        },
        /// AND n
        0xE6: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let result = ALU.and(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        // RST n RST 20
        0xE7: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
            context.cpu.programCounter = 0x20
        },
        /// ADD SP
        0xE8: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let signedValue = Int8(bitPattern: value)
            let halfCarry = ALU.checkCarry(context.cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 3)
            let carry = ALU.checkCarry(context.cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 7)
            context.cpu.stackPointer = context.cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
            
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(halfCarry),
                carry: .some(carry)
            )
            context.cpu.updateFlag(flag)
        },
        /// JP nn
        0xE9: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.programCounter = context.cpu.registerHL.all
        },
        /// LD (nn), A
        0xEA: InstructionBuilderV4(cycles: 4) { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            context.write(context.cpu.registerAF.hi, to: address)
        },
        /// XOR n
        0xEE: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let result = ALU.xor(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        // RST n RST 28
        0xEF: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
            context.cpu.programCounter = 0x28
        },
        
        // MARK: - 0xF0
        /// LDH A, (n)
        0xF0: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            let value = context.read(address)
            context.cpu.registerAF.hi = value
        },
        /// POP rr
        0xF1: InstructionBuilderV4(cycles: 3) { context in
            let leastSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            let mostSignificantByte = context.read(context.cpu.stackPointer)
            context.cpu.stackPointer += 1
            context.cpu.registerAF.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte & 0xF0)
        },
        /// LDH  A, (C)
        0xF2: InstructionBuilderV4(cycles: 2) { context in
            let leastSignificantByte = context.cpu.registerBC.lo
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            context.cpu.registerAF.hi = context.read(address)
        },
        /// DI
        0xF3: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.interruptMasterEnabled = false
        },
        /// PUSH rr
        0xF5: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(context.cpu.registerAF.hi, to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(context.cpu.registerAF.lo, to: context.cpu.stackPointer)
        },
        /// OR n
        0xF6: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let result = ALU.or(context.cpu.registerAF.hi, value)
            context.cpu.registerAF.hi = result.value
            context.cpu.updateFlag(result.flag)
        },
        // RST n RST 30
        0xF7: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
            context.cpu.programCounter = 0x30
        },
        /// LD HL, SP+e
        0xF8: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let signedValue = Int8(bitPattern: value)
            let halfCarry = ALU.checkCarry(context.cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 3)
            let carry = ALU.checkCarry(context.cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 7)
            context.cpu.registerHL.all = context.cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
            context.cpu.updateFlag(
                ALU.Flag(
                    zero: .some(false),
                    subtract: .some(false),
                    halfCarry: .some(halfCarry),
                    carry: .some(carry)
                )
            )
        },
        /// LD SP, HL
        0xF9: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.stackPointer = context.cpu.registerHL.all
        },
        /// LD A, (nn)
        0xFA: InstructionBuilderV4(cycles: 4) { context in
            let leastSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let mostSignificantByte = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            context.cpu.registerAF.hi = context.read(address)
        },
        /// DI
        0xFB: InstructionBuilderV4(cycles: 1) { context in
            context.cpu.isInterruptMasterEnabledRequest = true
        },
        /// CP n
        0xFE: InstructionBuilderV4(cycles: 2) { context in
            let value = context.read(context.cpu.programCounter)
            context.cpu.programCounter += 1
            let result = ALU.sub(context.cpu.registerAF.hi, value)
            context.cpu.updateFlag(result.flag)
        },
        // RST n RST 38
        0xFF: InstructionBuilderV4(cycles: 4) { context in
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter >> 8), to: context.cpu.stackPointer)
            context.cpu.stackPointer -= 1
            context.write(UInt8(context.cpu.programCounter & 0xFF), to: context.cpu.stackPointer)
            context.cpu.programCounter = 0x38
        },
    ]
    
    static let prefixInstruction: [UInt8: InstructionBuilderV4] = [
        // MARK: - 0x0
        /// RLC r
        0x00: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerBC.hi.bit(7)
            let shiftedValue = (context.cpu.registerBC.hi << 1) | bit7.toUInt8()
            context.cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RLC r
        0x01: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerBC.lo.bit(7)
            let shiftedValue = (context.cpu.registerBC.lo << 1) | bit7.toUInt8()
            context.cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RLC r
        0x02: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerDE.hi.bit(7)
            let shiftedValue = (context.cpu.registerDE.hi << 1) | bit7.toUInt8()
            context.cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RLC r
        0x03: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerDE.lo.bit(7)
            let shiftedValue = (context.cpu.registerDE.lo << 1) | bit7.toUInt8()
            context.cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RLC r
        0x04: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerHL.hi.bit(7)
            let shiftedValue = (context.cpu.registerHL.hi << 1) | bit7.toUInt8()
            context.cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RLC r
        0x05: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerHL.lo.bit(7)
            let shiftedValue = (context.cpu.registerHL.lo << 1) | bit7.toUInt8()
            context.cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RLC HL
        0x06: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all)
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1) | bit7.toUInt8()
            context.write(shiftedValue, to: context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RLC r
        0x07: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerAF.hi.bit(7)
            let shiftedValue = (context.cpu.registerAF.hi << 1) | bit7.toUInt8()
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x08: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerBC.hi.bit(0)
            let shiftedValue = (context.cpu.registerBC.hi >> 1) | (bit0.toUInt8() << 7)
            context.cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x09: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerBC.lo.bit(0)
            let shiftedValue = (context.cpu.registerBC.lo >> 1) | (bit0.toUInt8() << 7)
            context.cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x0A: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerDE.hi.bit(0)
            let shiftedValue = (context.cpu.registerDE.hi >> 1) | (bit0.toUInt8() << 7)
            context.cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x0B: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerDE.lo.bit(0)
            let shiftedValue = (context.cpu.registerDE.lo >> 1) | (bit0.toUInt8() << 7)
            context.cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x0C: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerHL.hi.bit(0)
            let shiftedValue = (context.cpu.registerHL.hi >> 1) | (bit0.toUInt8() << 7)
            context.cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x0D: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerHL.lo.bit(0)
            let shiftedValue = (context.cpu.registerHL.lo >> 1) | (bit0.toUInt8() << 7)
            context.cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC HL
        0x0E: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all)
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (bit0.toUInt8() << 7)
            context.write(shiftedValue, to: context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x0F: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerAF.hi.bit(0)
            let shiftedValue = (context.cpu.registerAF.hi >> 1) | (bit0.toUInt8() << 7)
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        // MARK: - 0x1
        /// RRC r
        0x10: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit7 = context.cpu.registerBC.hi.bit(7)
            let shiftedValue = (context.cpu.registerBC.hi << 1) | carry
            context.cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x11: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit7 = context.cpu.registerBC.lo.bit(7)
            let shiftedValue = (context.cpu.registerBC.lo << 1) | carry
            context.cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x12: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit7 = context.cpu.registerDE.hi.bit(7)
            let shiftedValue = (context.cpu.registerDE.hi << 1) | carry
            context.cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x13: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit7 = context.cpu.registerDE.lo.bit(7)
            let shiftedValue = (context.cpu.registerDE.lo << 1) | carry
            context.cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x14: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit7 = context.cpu.registerHL.hi.bit(7)
            let shiftedValue = (context.cpu.registerHL.hi << 1) | carry
            context.cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x15: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit7 = context.cpu.registerHL.lo.bit(7)
            let shiftedValue = (context.cpu.registerHL.lo << 1) | carry
            context.cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC HL
        0x16: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all)
            let carry = context.cpu.carryFlag.toUInt8()
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1) | carry
            context.write(shiftedValue, to: context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RRC r
        0x17: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit7 = context.cpu.registerAF.hi.bit(7)
            let shiftedValue = (context.cpu.registerAF.hi << 1) | carry
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// RR r
        0x18: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit0 = context.cpu.registerBC.hi.bit(0)
            let shiftedValue = (context.cpu.registerBC.hi >> 1) | (carry << 7)
            context.cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RR r
        0x19: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit0 = context.cpu.registerBC.lo.bit(0)
            let shiftedValue = (context.cpu.registerBC.lo >> 1) | (carry << 7)
            context.cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RR r
        0x1A: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit0 = context.cpu.registerDE.hi.bit(0)
            let shiftedValue = (context.cpu.registerDE.hi >> 1) | (carry << 7)
            context.cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RR r
        0x1B: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit0 = context.cpu.registerDE.lo.bit(0)
            let shiftedValue = (context.cpu.registerDE.lo >> 1) | (carry << 7)
            context.cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RR r
        0x1C: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit0 = context.cpu.registerHL.hi.bit(0)
            let shiftedValue = (context.cpu.registerHL.hi >> 1) | (carry << 7)
            context.cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RR r
        0x1D: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit0 = context.cpu.registerHL.lo.bit(0)
            let shiftedValue = (context.cpu.registerHL.lo >> 1) | (carry << 7)
            context.cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RR HL
        0x1E: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all)
            let carry = context.cpu.carryFlag.toUInt8()
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (carry << 7)
            context.write(shiftedValue, to: context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// RR r
        0x1F: InstructionBuilderV4(cycles: 2) { context in
            let carry = context.cpu.carryFlag.toUInt8()
            let bit0 = context.cpu.registerAF.hi.bit(0)
            let shiftedValue = (context.cpu.registerAF.hi >> 1) | (carry << 7)
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        
        // MARK: - 0x2
        /// SLA r
        0x20: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerBC.hi.bit(7)
            let shiftedValue = (context.cpu.registerBC.hi << 1)
            context.cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// SLA r
        0x21: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerBC.lo.bit(7)
            let shiftedValue = (context.cpu.registerBC.lo << 1)
            context.cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// SLA r
        0x22: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerDE.hi.bit(7)
            let shiftedValue = (context.cpu.registerDE.hi << 1)
            context.cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// SLA r
        0x23: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerDE.lo.bit(7)
            let shiftedValue = (context.cpu.registerDE.lo << 1)
            context.cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// SLA r
        0x24: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerHL.hi.bit(7)
            let shiftedValue = (context.cpu.registerHL.hi << 1)
            context.cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// SLA r
        0x25: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerHL.lo.bit(7)
            let shiftedValue = (context.cpu.registerHL.lo << 1)
            context.cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// SLA HL
        0x26: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all)
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1)
            context.write(shiftedValue, to: context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// SLA r
        0x27: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerAF.hi.bit(7)
            let shiftedValue = (context.cpu.registerAF.hi << 1)
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRA r
        0x28: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerBC.hi.bit(7)
            let bit0 = context.cpu.registerBC.hi.bit(0)
            let shiftedValue = (context.cpu.registerBC.hi >> 1) | (bit7.toUInt8() << 7)
            context.cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRA r
        0x29: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerBC.lo.bit(7)
            let bit0 = context.cpu.registerBC.lo.bit(0)
            let shiftedValue = (context.cpu.registerBC.lo >> 1) | (bit7.toUInt8() << 7)
            context.cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRA r
        0x2A: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerDE.hi.bit(7)
            let bit0 = context.cpu.registerDE.hi.bit(0)
            let shiftedValue = (context.cpu.registerDE.hi >> 1) | (bit7.toUInt8() << 7)
            context.cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRA r
        0x2B: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerDE.lo.bit(7)
            let bit0 = context.cpu.registerDE.lo.bit(0)
            let shiftedValue = (context.cpu.registerDE.lo >> 1) | (bit7.toUInt8() << 7)
            context.cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRA r
        0x2C: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerHL.hi.bit(7)
            let bit0 = context.cpu.registerHL.hi.bit(0)
            let shiftedValue = (context.cpu.registerHL.hi >> 1) | (bit7.toUInt8() << 7)
            context.cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRA r
        0x2D: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerHL.lo.bit(7)
            let bit0 = context.cpu.registerHL.lo.bit(0)
            let shiftedValue = (context.cpu.registerHL.lo >> 1) | (bit7.toUInt8() << 7)
            context.cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRA HL
        0x2E: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all)
            let bit7 = value.bit(7)
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (bit7.toUInt8() << 7)
            context.write(shiftedValue, to: context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRA r
        0x2F: InstructionBuilderV4(cycles: 2) { context in
            let bit7 = context.cpu.registerAF.hi.bit(7)
            let bit0 = context.cpu.registerAF.hi.bit(0)
            let shiftedValue = (context.cpu.registerAF.hi >> 1) | (bit7.toUInt8() << 7)
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        
        // MARK: - 0x3
        /// SWAP r
        0x30: InstructionBuilderV4(cycles: 2) { context in
            let highNibbles = (context.cpu.registerBC.hi & 0xF0) >> 4
            let lowNibbles = (context.cpu.registerBC.hi & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            context.cpu.registerBC.hi = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            context.cpu.updateFlag(flag)
        },
        /// SWAP r
        0x31: InstructionBuilderV4(cycles: 2) { context in
            let highNibbles = (context.cpu.registerBC.lo & 0xF0) >> 4
            let lowNibbles = (context.cpu.registerBC.lo & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            context.cpu.registerBC.lo = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            context.cpu.updateFlag(flag)
        },
        /// SWAP r
        0x32: InstructionBuilderV4(cycles: 2) { context in
            let highNibbles = (context.cpu.registerDE.hi & 0xF0) >> 4
            let lowNibbles = (context.cpu.registerDE.hi & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            context.cpu.registerDE.hi = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            context.cpu.updateFlag(flag)
        },
        /// SWAP r
        0x33: InstructionBuilderV4(cycles: 2) { context in
            let highNibbles = (context.cpu.registerDE.lo & 0xF0) >> 4
            let lowNibbles = (context.cpu.registerDE.lo & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            context.cpu.registerDE.lo = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            context.cpu.updateFlag(flag)
        },
        /// SWAP r
        0x34: InstructionBuilderV4(cycles: 2) { context in
            let highNibbles = (context.cpu.registerHL.hi & 0xF0) >> 4
            let lowNibbles = (context.cpu.registerHL.hi & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            context.cpu.registerHL.hi = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            context.cpu.updateFlag(flag)
        },
        /// SWAP r
        0x35: InstructionBuilderV4(cycles: 2) { context in
            let highNibbles = (context.cpu.registerHL.lo & 0xF0) >> 4
            let lowNibbles = (context.cpu.registerHL.lo & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            context.cpu.registerHL.lo = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            context.cpu.updateFlag(flag)
        },
        /// SWAP HL
        0x36: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all)
            let highNibbles = (value & 0xF0) >> 4
            let lowNibbles = (value & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            context.write(swappedValue, to: context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            context.cpu.updateFlag(flag)
        },
        /// SWAP r
        0x37: InstructionBuilderV4(cycles: 2) { context in
            let highNibbles = (context.cpu.registerAF.hi & 0xF0) >> 4
            let lowNibbles = (context.cpu.registerAF.hi & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            context.cpu.registerAF.hi = swappedValue
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRL r
        0x38: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerBC.hi.bit(0)
            let shiftedValue = context.cpu.registerBC.hi >> 1
            context.cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRL r
        0x39: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerBC.lo.bit(0)
            let shiftedValue = context.cpu.registerBC.lo >> 1
            context.cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRL r
        0x3A: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerDE.hi.bit(0)
            let shiftedValue = context.cpu.registerDE.hi >> 1
            context.cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRL r
        0x3B: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerDE.lo.bit(0)
            let shiftedValue = context.cpu.registerDE.lo >> 1
            context.cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRL r
        0x3C: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerHL.hi.bit(0)
            let shiftedValue = context.cpu.registerHL.hi >> 1
            context.cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRL r
        0x3D: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerHL.lo.bit(0)
            let shiftedValue = context.cpu.registerHL.lo >> 1
            context.cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRL HL
        0x3E: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all)
            let bit0 = value.bit(0)
            let shiftedValue = value >> 1
            context.write(shiftedValue, to: context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// SRL r
        0x3F: InstructionBuilderV4(cycles: 2) { context in
            let bit0 = context.cpu.registerAF.hi.bit(0)
            let shiftedValue = context.cpu.registerAF.hi >> 1
            context.cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x40: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x41: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x42: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x43: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x44: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x45: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x46: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x47: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerAF.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x48: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x49: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4A: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4B: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4C: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4D: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x4E: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x4F: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerAF.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x50: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x51: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x52: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x53: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x54: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x55: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x56: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x57: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerAF.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x58: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x59: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5A: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5B: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5C: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5D: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x5E: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x5F: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerAF.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x60: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x61: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x62: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x63: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x64: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x65: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x66: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x67: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerAF.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x68: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x69: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6A: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6B: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6C: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6D: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x6E: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x6F: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerAF.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x70: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x71: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x72: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x73: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x74: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x75: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x76: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x77: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerAF.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x78: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x79: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerBC.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7A: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7B: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerDE.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7C: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7D: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerHL.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, (HL)
        0x7E: InstructionBuilderV4(cycles: 3) { context in
            let value = context.read(context.cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// BIT b, r
        0x7F: InstructionBuilderV4(cycles: 2) { context in
            let flag = ALU.Flag(
                zero: .some(context.cpu.registerAF.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            context.cpu.updateFlag(flag)
        },
        /// RES b, r
        0x80: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitUnset(at: 0)
        },
        /// RES b, r
        0x81: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitUnset(at: 0)
        },
        /// RES b, r
        0x82: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitUnset(at: 0)
        },
        /// RES b, r
        0x83: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitUnset(at: 0)
        },
        /// RES b, r
        0x84: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitUnset(at: 0)
        },
        /// RES b, r
        0x85: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitUnset(at: 0)
        },
        /// RES b, HL
        0x86: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitUnset(at: 0)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0x87: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitUnset(at: 0)
        },
        /// RES b, r
        0x88: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitUnset(at: 1)
        },
        /// RES b, r
        0x89: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitUnset(at: 1)
        },
        /// RES b, r
        0x8A: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitUnset(at: 1)
        },
        /// RES b, r
        0x8B: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitUnset(at: 1)
        },
        /// RES b, r
        0x8C: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitUnset(at: 1)
        },
        /// RES b, r
        0x8D: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitUnset(at: 1)
        },
        /// RES b, HL
        0x8E: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitUnset(at: 1)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0x8F: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitUnset(at: 1)
        },
        /// RES b, r
        0x90: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitUnset(at: 2)
        },
        /// RES b, r
        0x91: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitUnset(at: 2)
        },
        /// RES b, r
        0x92: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitUnset(at: 2)
        },
        /// RES b, r
        0x93: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitUnset(at: 2)
        },
        /// RES b, r
        0x94: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitUnset(at: 2)
        },
        /// RES b, r
        0x95: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitUnset(at: 2)
        },
        /// RES b, HL
        0x96: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitUnset(at: 2)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0x97: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitUnset(at: 2)
        },
        /// RES b, r
        0x98: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitUnset(at: 3)
        },
        /// RES b, r
        0x99: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitUnset(at: 3)
        },
        /// RES b, r
        0x9A: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitUnset(at: 3)
        },
        /// RES b, r
        0x9B: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitUnset(at: 3)
        },
        /// RES b, r
        0x9C: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitUnset(at: 3)
        },
        /// RES b, r
        0x9D: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitUnset(at: 3)
        },
        /// RES b, HL
        0x9E: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitUnset(at: 3)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0x9F: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitUnset(at: 3)
        },
        /// RES b, r
        0xA0: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA1: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA2: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA3: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA4: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA5: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitUnset(at: 4)
        },
        /// RES b, HL
        0xA6: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitUnset(at: 4)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xA7: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitUnset(at: 4)
        },
        /// RES b, r
        0xA8: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitUnset(at: 5)
        },
        /// RES b, r
        0xA9: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitUnset(at: 5)
        },
        /// RES b, r
        0xAA: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitUnset(at: 5)
        },
        /// RES b, r
        0xAB: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitUnset(at: 5)
        },
        /// RES b, r
        0xAC: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitUnset(at: 5)
        },
        /// RES b, r
        0xAD: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitUnset(at: 5)
        },
        /// RES b, HL
        0xAE: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitUnset(at: 5)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xAF: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitUnset(at: 5)
        },
        /// RES b, r
        0xB0: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB1: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB2: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB3: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB4: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB5: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitUnset(at: 6)
        },
        /// RES b, HL
        0xB6: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitUnset(at: 6)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xB7: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitUnset(at: 6)
        },
        /// RES b, r
        0xB8: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitUnset(at: 7)
        },
        /// RES b, r
        0xB9: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitUnset(at: 7)
        },
        /// RES b, r
        0xBA: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitUnset(at: 7)
        },
        /// RES b, r
        0xBB: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitUnset(at: 7)
        },
        /// RES b, r
        0xBC: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitUnset(at: 7)
        },
        /// RES b, r
        0xBD: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitUnset(at: 7)
        },
        /// RES b, HL
        0xBE: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitUnset(at: 7)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xBF: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitUnset(at: 7)
        },
        /// RES b, r
        0xC0: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitSet(at: 0)
        },
        /// RES b, r
        0xC1: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitSet(at: 0)
        },
        /// RES b, r
        0xC2: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitSet(at: 0)
        },
        /// RES b, r
        0xC3: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitSet(at: 0)
        },
        /// RES b, r
        0xC4: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitSet(at: 0)
        },
        /// RES b, r
        0xC5: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitSet(at: 0)
        },
        /// RES b, HL
        0xC6: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitSet(at: 0)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xC7: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitSet(at: 0)
        },
        /// RES b, r
        0xC8: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitSet(at: 1)
        },
        /// RES b, r
        0xC9: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitSet(at: 1)
        },
        /// RES b, r
        0xCA: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitSet(at: 1)
        },
        /// RES b, r
        0xCB: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitSet(at: 1)
        },
        /// RES b, r
        0xCC: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitSet(at: 1)
        },
        /// RES b, r
        0xCD: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitSet(at: 1)
        },
        /// RES b, HL
        0xCE: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitSet(at: 1)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xCF: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitSet(at: 1)
        },
        /// RES b, r
        0xD0: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitSet(at: 2)
        },
        /// RES b, r
        0xD1: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitSet(at: 2)
        },
        /// RES b, r
        0xD2: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitSet(at: 2)
        },
        /// RES b, r
        0xD3: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitSet(at: 2)
        },
        /// RES b, r
        0xD4: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitSet(at: 2)
        },
        /// RES b, r
        0xD5: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitSet(at: 2)
        },
        /// RES b, HL
        0xD6: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitSet(at: 2)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xD7: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitSet(at: 2)
        },
        /// RES b, r
        0xD8: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitSet(at: 3)
        },
        /// RES b, r
        0xD9: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitSet(at: 3)
        },
        /// RES b, r
        0xDA: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitSet(at: 3)
        },
        /// RES b, r
        0xDB: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitSet(at: 3)
        },
        /// RES b, r
        0xDC: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitSet(at: 3)
        },
        /// RES b, r
        0xDD: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitSet(at: 3)
        },
        /// RES b, HL
        0xDE: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitSet(at: 3)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xDF: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitSet(at: 3)
        },
        /// RES b, r
        0xE0: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitSet(at: 4)
        },
        /// RES b, r
        0xE1: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitSet(at: 4)
        },
        /// RES b, r
        0xE2: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitSet(at: 4)
        },
        /// RES b, r
        0xE3: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitSet(at: 4)
        },
        /// RES b, r
        0xE4: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitSet(at: 4)
        },
        /// RES b, r
        0xE5: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitSet(at: 4)
        },
        /// RES b, HL
        0xE6: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitSet(at: 4)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xE7: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitSet(at: 4)
        },
        /// RES b, r
        0xE8: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitSet(at: 5)
        },
        /// RES b, r
        0xE9: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitSet(at: 5)
        },
        /// RES b, r
        0xEA: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitSet(at: 5)
        },
        /// RES b, r
        0xEB: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitSet(at: 5)
        },
        /// RES b, r
        0xEC: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitSet(at: 5)
        },
        /// RES b, r
        0xED: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitSet(at: 5)
        },
        /// RES b, HL
        0xEE: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitSet(at: 5)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xEF: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitSet(at: 5)
        },
        /// RES b, r
        0xF0: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitSet(at: 6)
        },
        /// RES b, r
        0xF1: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitSet(at: 6)
        },
        /// RES b, r
        0xF2: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitSet(at: 6)
        },
        /// RES b, r
        0xF3: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitSet(at: 6)
        },
        /// RES b, r
        0xF4: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitSet(at: 6)
        },
        /// RES b, r
        0xF5: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitSet(at: 6)
        },
        /// RES b, HL
        0xF6: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitSet(at: 6)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xF7: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitSet(at: 6)
        },
        /// RES b, r
        0xF8: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.hi = context.cpu.registerBC.hi.withBitSet(at: 7)
        },
        /// RES b, r
        0xF9: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerBC.lo = context.cpu.registerBC.lo.withBitSet(at: 7)
        },
        /// RES b, r
        0xFA: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.hi = context.cpu.registerDE.hi.withBitSet(at: 7)
        },
        /// RES b, r
        0xFB: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerDE.lo = context.cpu.registerDE.lo.withBitSet(at: 7)
        },
        /// RES b, r
        0xFC: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.hi = context.cpu.registerHL.hi.withBitSet(at: 7)
        },
        /// RES b, r
        0xFD: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerHL.lo = context.cpu.registerHL.lo.withBitSet(at: 7)
        },
        /// RES b, HL
        0xFE: InstructionBuilderV4(cycles: 4) { context in
            let value = context.read(context.cpu.registerHL.all).withBitSet(at: 7)
            context.write(value, to: context.cpu.registerHL.all)
        },
        /// RES b, r
        0xFF: InstructionBuilderV4(cycles: 2) { context in
            context.cpu.registerAF.hi = context.cpu.registerAF.hi.withBitSet(at: 7)
        },
    ]
}
