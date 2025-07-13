//
//  Instruction.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 2/7/2568 BE.
//

import Foundation

struct InstructionBuilder {
    /// Machine cyle : 1 Machine cycle = 4 clock cycles
    let build: (inout CPU) -> Instruction
    
    init(cycles: Int, perform: @escaping (inout CPU) -> Void) {
        self.build = { _ in
            Instruction(cycles: cycles, perform: perform)
        }
    }
    
    init(perform: @escaping (inout CPU) -> Instruction) {
        self.build = { cpu in
            perform(&cpu)
        }
    }
}

struct Instruction {
    let cycles: Int
    let perform: (inout CPU) -> Void
    
    init(cycles: Int, perform: @escaping (inout CPU) -> Void) {
        self.cycles = cycles
        self.perform = perform
    }
}

extension InstructionBuilder {
    static let instructions: [UInt8: InstructionBuilder] = [
        // MARK: - 0x00
        /// NOP
        0x00: InstructionBuilder(cycles: 1) { cpu in
            /// Do Nothing
        },
        /// LD rr 16 bit
        0x01: InstructionBuilder(cycles: 3) { cpu in
            let leastSignificantByte = cpu.readNextByteAndProceed()
            let mostSignificantByte = cpu.readNextByteAndProceed()
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerBC.all = value
        },
        /// LD (BC), A
        0x02: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.registerAF.hi
            cpu.writeValue(value, toMemoryAt: cpu.registerBC.all)
        },
        /// INC rr
        0x03: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.all &+= 1
        },
        /// INC r
        0x04: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.increment(cpu.registerBC.hi)
            cpu.registerBC.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// DEC r
        0x05: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.decrement(cpu.registerBC.hi)
            cpu.registerBC.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x06: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.readNextByteAndProceed()
        },
        /// RLCA
        0x07: InstructionBuilder(cycles: 1) { cpu in
            let bit7 = cpu.registerAF.hi.bit(7)
            let shiftedValue = (cpu.registerAF.hi << 1) | bit7.toUInt8()
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// LD (nn), SP
        0x08: InstructionBuilder(cycles: 5) { cpu in
            let leastSignificantAddressByte = cpu.readNextByteAndProceed()
            let mostSignificantAddressByte = cpu.readNextByteAndProceed()
            let address = (UInt16(mostSignificantAddressByte) << 8) | UInt16(leastSignificantAddressByte)
            
            let leastSignificantDataByte = UInt8(cpu.stackPointer)
            cpu.writeValue(leastSignificantDataByte, toMemoryAt: address)
            
            let mostSignificantDataByte = UInt8(cpu.stackPointer >> 8)
            cpu.writeValue(mostSignificantDataByte, toMemoryAt: address + 1)
        },
        /// ADD HL
        0x09: InstructionBuilder(cycles: 2) { cpu in
            let result = ALU.add16(cpu.registerHL.all, cpu.registerBC.all)
            cpu.registerHL.all = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LD A, (BC) Load to the 8-bit A register, data from the absolute address specified by the 16-bit register BC.
        0x0A: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.memory(at: cpu.registerBC.all)
        },
        /// DEC rr
        0x0B: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.all &-= 1
        },
        /// INC r
        0x0C: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.increment(cpu.registerBC.lo)
            cpu.registerBC.lo = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// DEC r
        0x0D: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.decrement(cpu.registerBC.lo)
            cpu.registerBC.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x0E: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.readNextByteAndProceed()
        },
        /// RRCA
        0x0F: InstructionBuilder(cycles: 1) { cpu in
            let bit0 = cpu.registerAF.hi.bit(0)
            let shiftedValue = (cpu.registerAF.hi >> 1) | (bit0.toUInt8() << 7)
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        
        // MARK: - 0x01
        /// LD rr 16 bit
        0x11: InstructionBuilder(cycles: 3) { cpu in
            let leastSignificantByte: UInt8 = cpu.readNextByteAndProceed()
            let mostSignificantByte: UInt8 = cpu.readNextByteAndProceed()
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerDE.all = value
        },
        /// LD (DE), A
        0x12: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.registerAF.hi
            cpu.writeValue(value, toMemoryAt: cpu.registerDE.all)
        },
        /// INC rr
        0x13: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.all &+= 1
        },
        /// INC r
        0x14: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.increment(cpu.registerDE.hi)
            cpu.registerDE.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// DEC r
        0x15: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.decrement(cpu.registerDE.hi)
            cpu.registerBC.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x16: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.readNextByteAndProceed()
        },
        /// RLA
        0x17: InstructionBuilder(cycles: 1) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// JR e
        0x18: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.readNextByteAndProceed()
            let signedValue = Int8(bitPattern: value)
            cpu.programCounter += UInt16(bitPattern: Int16(signedValue))
        },
        /// ADD HL
        0x19: InstructionBuilder(cycles: 2) { cpu in
            let result = ALU.add16(cpu.registerHL.all, cpu.registerDE.all)
            cpu.registerHL.all = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LD A, (BC) Load to the 8-bit A register, data from the absolute address specified by the 16-bit register BC.
        0x1A: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.memory(at: cpu.registerDE.all)
        },
        /// DEC rr
        0x1B: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.all &-= 1
        },
        /// INC r
        0x1C: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.increment(cpu.registerDE.lo)
            cpu.registerDE.lo = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// DEC r
        0x1D: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.decrement(cpu.registerDE.lo)
            cpu.registerBC.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x1E: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.readNextByteAndProceed()
        },
        /// RRA
        0x1F: InstructionBuilder(cycles: 1) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        
        // MARK: - 0x02
        /// JR cc, e
        0x20: InstructionBuilder { cpu in
            if !cpu.zeroFlag {
                return Instruction(cycles: 3) { cpu in
                    let value = cpu.readNextByteAndProceed()
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter += UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return Instruction(cycles: 2) { _ in }
            }
        },
        /// LD rr 16 bit
        0x21: InstructionBuilder(cycles: 3) { cpu in
            let leastSignificantByte: UInt8 = cpu.readNextByteAndProceed()
            let mostSignificantByte: UInt8 = cpu.readNextByteAndProceed()
            let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerHL.all = value
        },
        /// LD (HL+), A
        0x22: InstructionBuilder(cycles: 2) { cpu in
            let address = cpu.registerHL.all
            cpu.writeValue(cpu.registerAF.hi, toMemoryAt: address)
            cpu.registerHL.all += 1
        },
        /// INC rr
        0x23: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.all &+= 1
        },
        /// INC r
        0x24: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.increment(cpu.registerHL.hi)
            cpu.registerHL.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// DEC r
        0x25: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.decrement(cpu.registerHL.hi)
            cpu.registerBC.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// DAA
        0x27: InstructionBuilder(cycles: 1) { cpu in
            //TODO: - Implement DAA Instruction
        },
        /// JR cc, e
        0x28: InstructionBuilder { cpu in
            if cpu.zeroFlag {
                return Instruction(cycles: 3) { cpu in
                    let value = cpu.readNextByteAndProceed()
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter += UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return Instruction(cycles: 2) { _ in }
            }
        },
        /// LDrn Load to 8 bit register r, the data n
        0x26: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.readNextByteAndProceed()
        },
        /// ADD HL
        0x29: InstructionBuilder(cycles: 2) { cpu in
            let result = ALU.add16(cpu.registerHL.all, cpu.registerHL.all)
            cpu.registerHL.all = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LD A, (HL+)
        0x2A: InstructionBuilder(cycles: 2) { cpu in
            let address = cpu.registerHL.all
            cpu.registerAF.hi = cpu.memory(at: address)
            cpu.registerHL.all += 1
        },
        /// DEC rr
        0x2B: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.all &-= 1
        },
        /// INC r
        0x2C: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.increment(cpu.registerHL.lo)
            cpu.registerHL.lo = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// DEC r
        0x2D: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.decrement(cpu.registerHL.lo)
            cpu.registerBC.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LDrn Load to 8 bit register r, the data n
        0x2E: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.readNextByteAndProceed()
        },
        /// LDrn Load to 8 bit register r, the data n
        0x2F: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerAF.hi = ~cpu.registerAF.hi
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(true),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        
        // MARK: - 0x03
        /// JR cc, e
        0x30: InstructionBuilder { cpu in
            if !cpu.carryFlag {
                return Instruction(cycles: 3) { cpu in
                    let value = cpu.readNextByteAndProceed()
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter += UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return Instruction(cycles: 2) { _ in }
            }
        },
        /// LD (HL-), A
        0x32: InstructionBuilder(cycles: 2) { cpu in
            let address = cpu.registerHL.all
            cpu.writeValue(cpu.registerAF.hi, toMemoryAt: address)
            cpu.registerHL.all -= 1
        },
        /// INC rr
        0x33: InstructionBuilder(cycles: 2) { cpu in
            cpu.stackPointer &+= 1
        },
        /// INC HL
        0x34: InstructionBuilder(cycles: 3) { cpu in
            let result = ALU.increment(cpu.memory(at: cpu.registerHL.all))
            cpu.writeValue(result.value, toMemoryAt: cpu.registerHL.all)
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// DEC HL
        0x35: InstructionBuilder(cycles: 3) { cpu in
            let result = ALU.decrement(cpu.memory(at: cpu.registerHL.all))
            cpu.writeValue(result.value, toMemoryAt: cpu.registerHL.all)
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LD (HL)
        0x36: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.readNextByteAndProceed()
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// SCF
        0x37: InstructionBuilder(cycles: 1) { cpu in
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(true)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// JR cc, e
        0x38: InstructionBuilder { cpu in
            if cpu.carryFlag {
                return Instruction(cycles: 3) { cpu in
                    let value = cpu.readNextByteAndProceed()
                    let signedValue = Int8(bitPattern: value)
                    cpu.programCounter += UInt16(bitPattern: Int16(signedValue))
                }
            } else {
                return Instruction(cycles: 2) { _ in }
            }
        },
        /// ADD HL
        0x39: InstructionBuilder(cycles: 2) { cpu in
            let result = ALU.add16(cpu.registerHL.all, cpu.stackPointer)
            cpu.registerHL.all = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// LD A, (HL-)
        0x3A: InstructionBuilder(cycles: 2) { cpu in
            let address = cpu.registerHL.all
            cpu.registerAF.hi = cpu.memory(at: address)
            cpu.registerHL.all -= 1
        },
        /// DEC rr
        0x3B: InstructionBuilder(cycles: 2) { cpu in
            cpu.stackPointer &-= 1
        },
        /// INC r
        0x3C: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.increment(cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// DEC r
        0x3D: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.decrement(cpu.registerAF.hi)
            cpu.registerBC.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// CCF
        0x3F: InstructionBuilder(cycles: 1) { cpu in
            let flag = ALU.Flag(
                zero: .noneAffected,
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(!cpu.carryFlag)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        
        // MARK: - 0x40
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x40: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x41: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x42: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x43: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x44: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x45: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x46: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.memory(at: cpu.registerHL.all)
        },
        /// LDrr`
        0x47: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.hi = cpu.registerAF.hi
        },
        /// LDrr`
        0x48: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.lo = cpu.registerBC.hi
        },
        /// LDrr`
        0x49: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo
        },
        /// LDrr`
        0x4A: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.lo = cpu.registerDE.hi
        },
        /// LDrr`
        0x4B: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.lo = cpu.registerDE.lo
        },
        /// LDrr`
        0x4C: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.lo = cpu.registerHL.hi
        },
        /// LDrr`
        0x4D: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.lo = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x4E: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.memory(at: cpu.registerHL.all)
        },
        /// LDrr`
        0x4F: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerBC.lo = cpu.registerAF.hi
        },
        // MARK: - 0x50
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x50: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x51: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x52: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x53: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x54: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x55: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x56: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.memory(at: cpu.registerHL.all)
        },
        /// LDrr`
        0x57: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.hi = cpu.registerAF.hi
        },
        /// LDrr`
        0x58: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.lo = cpu.registerBC.hi
        },
        /// LDrr`
        0x59: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.lo = cpu.registerBC.lo
        },
        /// LDrr`
        0x5A: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.lo = cpu.registerDE.hi
        },
        /// LDrr`
        0x5B: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo
        },
        /// LDrr`
        0x5C: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.lo = cpu.registerHL.hi
        },
        /// LDrr`
        0x5D: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.lo = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x5E: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.memory(at: cpu.registerHL.all)
        },
        /// LDrr`
        0x5F: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerDE.lo = cpu.registerAF.hi
        },
        
        // MARK: - 0x60
        /// LDrr` Load to 8 bit register r, from 8-bit register r`
        0x60: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x61: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x62: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x63: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x64: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x65: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x66: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.hi = cpu.memory(at: cpu.registerHL.all)
        },
        /// LDrr`
        0x67: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerAF.hi
        },
        /// LDrr`
        0x68: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.lo = cpu.registerBC.hi
        },
        /// LDrr`
        0x69: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.lo = cpu.registerBC.lo
        },
        /// LDrr`
        0x6A: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.lo = cpu.registerDE.hi
        },
        /// LDrr`
        0x6B: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.lo = cpu.registerDE.lo
        },
        /// LDrr`
        0x6C: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.lo = cpu.registerHL.hi
        },
        /// LDrr`
        0x6D: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x6E: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.memory(at: cpu.registerHL.all)
        },
        /// LDrr`
        0x6F: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerHL.lo = cpu.registerAF.hi
        },
        
        // MARK: - 0x70
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x70: InstructionBuilder(cycles: 2) { cpu in
            cpu.writeValue(cpu.registerBC.hi, toMemoryAt: cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x71: InstructionBuilder(cycles: 2) { cpu in
            cpu.writeValue(cpu.registerBC.lo, toMemoryAt: cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x72: InstructionBuilder(cycles: 2) { cpu in
            cpu.writeValue(cpu.registerDE.hi, toMemoryAt: cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x73: InstructionBuilder(cycles: 2) { cpu in
            cpu.writeValue(cpu.registerDE.lo, toMemoryAt: cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x74: InstructionBuilder(cycles: 2) { cpu in
            cpu.writeValue(cpu.registerHL.hi, toMemoryAt: cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x75: InstructionBuilder(cycles: 2) { cpu in
            cpu.writeValue(cpu.registerHL.lo, toMemoryAt: cpu.registerHL.all)
        },
        //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
        0x77: InstructionBuilder(cycles: 2) { cpu in
            cpu.writeValue(cpu.registerAF.hi, toMemoryAt: cpu.registerHL.all)
        },
        /// LDrr`
        0x78: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerAF.hi = cpu.registerBC.hi
        },
        /// LDrr`
        0x79: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerAF.hi = cpu.registerBC.lo
        },
        /// LDrr`
        0x7A: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerAF.hi = cpu.registerDE.hi
        },
        /// LDrr`
        0x7B: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerAF.hi = cpu.registerDE.lo
        },
        /// LDrr`
        0x7C: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerAF.hi = cpu.registerHL.hi
        },
        /// LDrr`
        0x7D: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerAF.hi = cpu.registerHL.lo
        },
        /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
        0x7E: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.memory(at: cpu.registerHL.all)
        },
        /// LDrr`
        0x7F: InstructionBuilder(cycles: 1) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi
        },
        
        // MARK: - 0x80
        /// ADD r
        0x80: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADD r
        0x81: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADD r
        0x82: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADD r
        0x83: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADD r
        0x84: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADD r
        0x85: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADD r
        0x87: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADC r
        0x88: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADC r
        0x89: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADC r
        0x8A: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADC r
        0x8B: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADC r
        0x8C: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADC r
        0x8D: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADC (HL)
        0x8E: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let result = ALU.add(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// ADC r
        0x8F: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.add(cpu.registerAF.hi, cpu.registerAF.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        
        // MARK: - 0x90
        /// SUB r
        0x90: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SUB r
        0x91: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SUB r
        0x92: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SUB r
        0x93: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SUB r
        0x94: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SUB r
        0x95: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SUB r
        0x96: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SUB r
        0x97: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SBC r
        0x98: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SBC r
        0x99: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SBC r
        0x9A: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SBC r
        0x9B: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SBC r
        0x9C: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SBC r
        0x9D: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SBC HL
        0x9E: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let result = ALU.sub(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// SBC r
        0x9F: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        // MARK: - 0xA0
        /// AND r
        0xA0: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// AND r
        0xA1: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// AND r
        0xA2: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// AND r
        0xA3: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// AND r
        0xA4: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// AND r
        0xA5: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// AND HL
        0xA6: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let result = ALU.and(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// AND r
        0xA7: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.and(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// XOR r
        0xA8: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// XOR r
        0xA9: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// XOR r
        0xAA: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// XOR r
        0xAB: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// XOR r
        0xAC: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// XOR r
        0xAD: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// XOR HL
        0xAE: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let result = ALU.xor(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// XOR r
        0xAF: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.xor(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        
        // MARK: - 0xB0
        /// OR r
        0xB0: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// OR r
        0xB1: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// OR r
        0xB2: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// OR r
        0xB3: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// OR r
        0xB4: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// OR r
        0xB5: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// OR HL
        0xB6: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let result = ALU.or(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// OR r
        0xB7: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.or(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        
        /// CP r
        0xB8: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi)
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// CP r
        0xB9: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo)
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// CP r
        0xBA: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi)
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// CP r
        0xBB: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo)
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// CP r
        0xBC: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi)
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// CP r
        0xBD: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo)
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// CP HL
        0xBE: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.updateFlagFromAluResult(result.flag)
        },
        /// CP r
        0xBF: InstructionBuilder(cycles: 1) { cpu in
            let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi)
            cpu.updateFlagFromAluResult(result.flag)
        },
        
        // MARK: - 0xC0
        /// RET CC
        0xC0: InstructionBuilder { cpu in
            if !cpu.zeroFlag {
                return Instruction(cycles: 5) { cpu in
                    let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return Instruction(cycles: 2) { _ in }
            }
        },
        /// POP rr
        0xC1: InstructionBuilder(cycles: 3) { cpu in
            let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerBC.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xC2: InstructionBuilder { cpu in
            if !cpu.zeroFlag {
                return Instruction(cycles: 4) { cpu in
                    let leastSignificantByte = cpu.readNextByteAndProceed()
                    let mostSignificantByte = cpu.readNextByteAndProceed()
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _ in }
            }
        },
        /// JP nn
        0xC3: InstructionBuilder(cycles: 4) { cpu in
            let leastSignificantByte = cpu.readNextByteAndProceed()
            let mostSignificantByte = cpu.readNextByteAndProceed()
            let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.programCounter = address
        },
        /// CALL cc, nn
        0xC4: InstructionBuilder { cpu in
            if !cpu.zeroFlag {
                return Instruction(cycles: 6) { cpu in
                    let leastSignificantByte = cpu.readNextByteAndProceed()
                    let mostSignificantByte = cpu.readNextByteAndProceed()
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _ in }
            }
        },
        /// PUSH rr
        0xC5: InstructionBuilder(cycles: 4) { cpu in
            cpu.stackPointer -= 1
            cpu.writeValue(cpu.registerBC.hi, toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(cpu.registerBC.lo, toMemoryAt: cpu.stackPointer)
        },
        /// ADD n
        0xC6: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.readNextByteAndProceed()
            let result = ALU.add(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        // RST n
        0xC7: InstructionBuilder(cycles: 4) { cpu in
            let mostSignificantByte = (cpu.programCounter >> 8) & 0xFF
            let leastSignificantByte = cpu.programCounter & 0xFF
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(mostSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(leastSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.programCounter = mostSignificantByte
        },
        /// RET CC
        0xC8: InstructionBuilder { cpu in
            if cpu.zeroFlag {
                return Instruction(cycles: 5) { cpu in
                    let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return Instruction(cycles: 2) { _ in }
            }
        },
        /// RET
        0xC9: InstructionBuilder(cycles: 4) { cpu in
            let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xCA: InstructionBuilder { cpu in
            if cpu.zeroFlag {
                return Instruction(cycles: 4) { cpu in
                    let leastSignificantByte = cpu.readNextByteAndProceed()
                    let mostSignificantByte = cpu.readNextByteAndProceed()
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _ in }
            }
        },
        /// CALL cc, nn
        0xCC: InstructionBuilder { cpu in
            if cpu.zeroFlag {
                return Instruction(cycles: 6) { cpu in
                    let leastSignificantByte = cpu.readNextByteAndProceed()
                    let mostSignificantByte = cpu.readNextByteAndProceed()
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _ in }
            }
        },
        /// CALL nn
        0xCD: InstructionBuilder(cycles: 6) { cpu in
            let leastSignificantByte = cpu.readNextByteAndProceed()
            let mostSignificantByte = cpu.readNextByteAndProceed()
            cpu.stackPointer -= 1
            cpu.writeValue(mostSignificantByte, toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(leastSignificantByte, toMemoryAt: cpu.stackPointer)
            cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// ADC n
        0xCE: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.readNextByteAndProceed()
            let result = ALU.add(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        // RST n
        0xCF: InstructionBuilder(cycles: 4) { cpu in
            let mostSignificantByte = (cpu.programCounter >> 8) & 0xFF
            let leastSignificantByte = cpu.programCounter & 0xFF
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(mostSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(leastSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.programCounter = (0x08 << 8) | mostSignificantByte
        },
        
        // MARK: - 0xD0
        /// RET CC
        0xD0: InstructionBuilder { cpu in
            if !cpu.carryFlag {
                return Instruction(cycles: 5) { cpu in
                    let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return Instruction(cycles: 2) { _ in }
            }
        },
        /// POP rr
        0xD1: InstructionBuilder(cycles: 3) { cpu in
            let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerDE.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// JP cc, nn
        0xD2: InstructionBuilder { cpu in
            if !cpu.carryFlag {
                return Instruction(cycles: 4) { cpu in
                    let leastSignificantByte = cpu.readNextByteAndProceed()
                    let mostSignificantByte = cpu.readNextByteAndProceed()
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _ in }
            }
        },
        /// CALL cc, nn
        0xD4: InstructionBuilder { cpu in
            if !cpu.carryFlag {
                return Instruction(cycles: 6) { cpu in
                    let leastSignificantByte = cpu.readNextByteAndProceed()
                    let mostSignificantByte = cpu.readNextByteAndProceed()
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _ in }
            }
        },
        /// PUSH rr
        0xD5: InstructionBuilder(cycles: 4) { cpu in
            cpu.stackPointer -= 1
            cpu.writeValue(cpu.registerDE.hi, toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(cpu.registerDE.lo, toMemoryAt: cpu.stackPointer)
        },
        /// SUB n
        0xD6: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.readNextByteAndProceed()
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        // RST n
        0xD7: InstructionBuilder(cycles: 4) { cpu in
            let mostSignificantByte = (cpu.programCounter >> 8) & 0xFF
            let leastSignificantByte = cpu.programCounter & 0xFF
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(mostSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(leastSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.programCounter = (0x10 << 8) | mostSignificantByte
        },
        /// RET CC
        0xD8: InstructionBuilder { cpu in
            if cpu.carryFlag {
                return Instruction(cycles: 5) { cpu in
                    let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
                    cpu.stackPointer += 1
                    let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
                    cpu.stackPointer += 1
                    cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                }
            } else {
                return Instruction(cycles: 2) { _ in }
            }
        },
        /// RET CC
        0xD9: InstructionBuilder(cycles: 4) { cpu in
            let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.interruptEnable = 1
        },
        /// JP cc, nn
        0xDA: InstructionBuilder { cpu in
            if cpu.carryFlag {
                return Instruction(cycles: 4) { cpu in
                    let leastSignificantByte = cpu.readNextByteAndProceed()
                    let mostSignificantByte = cpu.readNextByteAndProceed()
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _ in }
            }
        },
        /// CALL cc, nn
        0xDC: InstructionBuilder { cpu in
            if cpu.zeroFlag {
                return Instruction(cycles: 6) { cpu in
                    let leastSignificantByte = cpu.readNextByteAndProceed()
                    let mostSignificantByte = cpu.readNextByteAndProceed()
                    let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
                    cpu.programCounter = address
                }
            } else {
                return Instruction(cycles: 3) { _ in }
            }
        },
        /// SBC n
        0xDE: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.readNextByteAndProceed()
            let result = ALU.sub(cpu.registerAF.hi, value, carry: cpu.carryFlag)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        // RST n
        0xDF: InstructionBuilder(cycles: 4) { cpu in
            let mostSignificantByte = (cpu.programCounter >> 8) & 0xFF
            let leastSignificantByte = cpu.programCounter & 0xFF
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(mostSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(leastSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.programCounter = (0x18 << 8) | mostSignificantByte
        },
        
        // MARK: - 0xE0
        /// LDH (C), A
        0xE0: InstructionBuilder(cycles: 3) { cpu in
            let leastSignificantByte = cpu.readNextByteAndProceed()
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            cpu.writeValue(cpu.registerAF.hi, toMemoryAt: address)
        },
        /// POP rr
        0xE1: InstructionBuilder(cycles: 3) { cpu in
            let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerHL.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// LDH (C), A
        0xE2: InstructionBuilder(cycles: 2) { cpu in
            let leastSignificantByte = cpu.registerBC.lo
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            cpu.writeValue(cpu.registerAF.hi, toMemoryAt: address)
        },
        /// PUSH rr
        0xE5: InstructionBuilder(cycles: 4) { cpu in
            cpu.stackPointer -= 1
            cpu.writeValue(cpu.registerHL.hi, toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(cpu.registerHL.lo, toMemoryAt: cpu.stackPointer)
        },
        /// AND n
        0xE6: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.readNextByteAndProceed()
            let result = ALU.and(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        // RST n
        0xE7: InstructionBuilder(cycles: 4) { cpu in
            let mostSignificantByte = (cpu.programCounter >> 8) & 0xFF
            let leastSignificantByte = cpu.programCounter & 0xFF
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(mostSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(leastSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.programCounter = (0x20 << 8) | mostSignificantByte
        },
        /// ADD SP
        0xE8: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.readNextByteAndProceed()
            let signedValue = Int8(bitPattern: value)
            cpu.stackPointer = cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
            let halfCarry = checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), atBit: 3)
            let carry = checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), atBit: 7)
            
            let flag = ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(halfCarry),
                carry: .some(carry)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// JP nn
        0xE9: InstructionBuilder(cycles: 1) { cpu in
            cpu.programCounter = cpu.registerHL.all
        },
        /// LD (nn), A
        0xEA: InstructionBuilder(cycles: 4) { cpu in
            let leastSignificantByte = cpu.readNextByteAndProceed()
            let mostSignificantByte = cpu.readNextByteAndProceed()
            let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.writeValue(cpu.registerAF.hi, toMemoryAt: address)
        },
        /// XOR n
        0xEE: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.readNextByteAndProceed()
            let result = ALU.xor(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        // RST n
        0xEF: InstructionBuilder(cycles: 4) { cpu in
            let mostSignificantByte = (cpu.programCounter >> 8) & 0xFF
            let leastSignificantByte = cpu.programCounter & 0xFF
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(mostSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(leastSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.programCounter = (0x28 << 8) | mostSignificantByte
        },
        
        // MARK: - 0xF0
        /// LDH A, (n)
        0xF0: InstructionBuilder(cycles: 3) { cpu in
            let leastSignificantByte = cpu.registerBC.lo
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            cpu.registerAF.hi = cpu.memory(at: address)
        },
        /// POP rr
        0xF1: InstructionBuilder(cycles: 3) { cpu in
            let leastSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            let mostSignificantByte = cpu.memory(at: cpu.stackPointer)
            cpu.stackPointer += 1
            cpu.registerAF.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        },
        /// LDH  A, (C)
        0xF2: InstructionBuilder(cycles: 2) { cpu in
            let leastSignificantByte = cpu.registerBC.lo
            let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
            cpu.registerAF.hi = cpu.memory(at: address)
        },
        /// DI
        0xF3: InstructionBuilder(cycles: 1) { cpu in
            cpu.interruptEnable = 0
        },
        /// PUSH rr
        0xF5: InstructionBuilder(cycles: 4) { cpu in
            cpu.stackPointer -= 1
            cpu.writeValue(cpu.registerAF.hi, toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(cpu.registerAF.lo, toMemoryAt: cpu.stackPointer)
        },
        /// OR n
        0xF6: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.readNextByteAndProceed()
            let result = ALU.or(cpu.registerAF.hi, value)
            cpu.registerAF.hi = result.value
            cpu.updateFlagFromAluResult(result.flag)
        },
        // RST n
        0xF7: InstructionBuilder(cycles: 4) { cpu in
            let mostSignificantByte = (cpu.programCounter >> 8) & 0xFF
            let leastSignificantByte = cpu.programCounter & 0xFF
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(mostSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(leastSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.programCounter = (0x30 << 8) | mostSignificantByte
        },
        /// LD HL, SP+e
        0xF8: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.readNextByteAndProceed()
            let signedValue = Int8(bitPattern: value)
            let flagH: UInt8 = checkCarry(UInt16(value), cpu.stackPointer, atBit: 3) ? 1 : 0
            let flagC: UInt8 = checkCarry(UInt16(value), cpu.stackPointer, atBit: 7) ? 1 : 0
            cpu.registerHL.all = cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
            cpu.registerAF.lo = createRegisterFValueFromFlag(z: 0, n: 0, h: flagH, c: flagC)
        },
        /// LD SP, HL
        0xF9: InstructionBuilder(cycles: 2) { cpu in
            cpu.stackPointer = cpu.registerHL.all
        },
        /// LD A, (nn)
        0xFA: InstructionBuilder(cycles: 4) { cpu in
            let leastSignificantByte = cpu.readNextByteAndProceed()
            let mostSignificantByte = cpu.readNextByteAndProceed()
            let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            cpu.registerAF.hi = cpu.memory(at: address)
        },
        /// DI
        0xFB: InstructionBuilder(cycles: 1) { cpu in
            cpu.interruptEnable = 1
        },
        /// CP n
        0xFE: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.readNextByteAndProceed()
            let result = ALU.sub(cpu.registerAF.hi, value)
            cpu.updateFlagFromAluResult(result.flag)
        },
        // RST n
        0xFF: InstructionBuilder(cycles: 4) { cpu in
            let mostSignificantByte = (cpu.programCounter >> 8) & 0xFF
            let leastSignificantByte = cpu.programCounter & 0xFF
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(mostSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.stackPointer -= 1
            cpu.writeValue(UInt8(leastSignificantByte), toMemoryAt: cpu.stackPointer)
            cpu.programCounter = (0x38 << 8) | mostSignificantByte
        },
    ]
    
    static let prefixInstruction: [UInt8: InstructionBuilder] = [
        // MARK: - 0x0
        /// RLC r
        0x00: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerBC.hi.bit(7)
            let shiftedValue = (cpu.registerBC.hi << 1) | bit7.toUInt8()
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RLC r
        0x01: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerBC.lo.bit(7)
            let shiftedValue = (cpu.registerBC.lo << 1) | bit7.toUInt8()
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RLC r
        0x02: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerDE.hi.bit(7)
            let shiftedValue = (cpu.registerDE.hi << 1) | bit7.toUInt8()
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RLC r
        0x03: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerDE.lo.bit(7)
            let shiftedValue = (cpu.registerDE.lo << 1) | bit7.toUInt8()
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RLC r
        0x04: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerHL.hi.bit(7)
            let shiftedValue = (cpu.registerHL.hi << 1) | bit7.toUInt8()
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RLC r
        0x05: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerHL.lo.bit(7)
            let shiftedValue = (cpu.registerHL.lo << 1) | bit7.toUInt8()
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RLC HL
        0x06: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1) | bit7.toUInt8()
            cpu.writeValue(shiftedValue, toMemoryAt: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RLC r
        0x07: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerAF.hi.bit(7)
            let shiftedValue = (cpu.registerAF.hi << 1) | bit7.toUInt8()
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x08: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerBC.hi.bit(0)
            let shiftedValue = (cpu.registerBC.hi >> 1) | (bit0.toUInt8() << 7)
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x09: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerBC.lo.bit(0)
            let shiftedValue = (cpu.registerBC.lo >> 1) | (bit0.toUInt8() << 7)
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x0A: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerDE.hi.bit(0)
            let shiftedValue = (cpu.registerDE.hi >> 1) | (bit0.toUInt8() << 7)
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x0B: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerDE.lo.bit(0)
            let shiftedValue = (cpu.registerDE.lo >> 1) | (bit0.toUInt8() << 7)
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x0C: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerHL.hi.bit(0)
            let shiftedValue = (cpu.registerHL.hi >> 1) | (bit0.toUInt8() << 7)
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x0D: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerHL.lo.bit(0)
            let shiftedValue = (cpu.registerHL.lo >> 1) | (bit0.toUInt8() << 7)
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC HL
        0x0E: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (bit0.toUInt8() << 7)
            cpu.writeValue(shiftedValue, toMemoryAt: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x0F: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerAF.hi.bit(0)
            let shiftedValue = (cpu.registerAF.hi >> 1) | (bit0.toUInt8() << 7)
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        // MARK: - 0x1
        /// RRC r
        0x10: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x11: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x12: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x13: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x14: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x15: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC HL
        0x16: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let carry = cpu.carryFlag.toUInt8()
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1) | carry
            cpu.writeValue(shiftedValue, toMemoryAt: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RRC r
        0x17: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RR r
        0x18: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RR r
        0x19: InstructionBuilder(cycles: 2) { cpu in
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = cpu.registerBC.lo.bit(0)
            let shiftedValue = (cpu.registerBC.hi >> 1) | (carry << 7)
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RR r
        0x1A: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RR r
        0x1B: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RR r
        0x1C: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RR r
        0x1D: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// RR HL
        0x1E: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let carry = cpu.carryFlag.toUInt8()
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (carry << 7)
            cpu.writeValue(shiftedValue, toMemoryAt: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RR r
        0x1F: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        
        // MARK: - 0x2
        /// SLA r
        0x20: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerBC.hi.bit(7)
            let shiftedValue = (cpu.registerBC.hi << 1)
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// SLA r
        0x21: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerBC.lo.bit(7)
            let shiftedValue = (cpu.registerBC.lo << 1)
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// SLA r
        0x22: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerDE.hi.bit(7)
            let shiftedValue = (cpu.registerDE.hi << 1)
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// SLA r
        0x23: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerDE.lo.bit(7)
            let shiftedValue = (cpu.registerDE.lo << 1)
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// SLA r
        0x24: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerHL.hi.bit(7)
            let shiftedValue = (cpu.registerHL.hi << 1)
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// SLA r
        0x25: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerHL.lo.bit(7)
            let shiftedValue = (cpu.registerHL.lo << 1)
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// SLA HL
        0x26: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let bit7 = value.bit(7)
            let shiftedValue = (value << 1)
            cpu.writeValue(shiftedValue, toMemoryAt: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// SLA r
        0x27: InstructionBuilder(cycles: 2) { cpu in
            let bit7 = cpu.registerAF.hi.bit(7)
            let shiftedValue = (cpu.registerAF.hi << 1)
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit7)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// SRA r
        0x28: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// SRA r
        0x29: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// SRA r
        0x2A: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// SRA r
        0x2B: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// SRA r
        0x2C: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// SRA r
        0x2D: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        /// SRA HL
        0x2E: InstructionBuilder(cycles: 2) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let bit7 = value.bit(7)
            let bit0 = value.bit(0)
            let shiftedValue = (value >> 1) | (bit7.toUInt8() << 7)
            cpu.writeValue(shiftedValue, toMemoryAt: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// SRA r
        0x2F: InstructionBuilder(cycles: 2) { cpu in
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
            cpu.updateFlagFromAluResult(flag)
        },
        
        // MARK: - 0x3
        /// SWAP r
        0x30: InstructionBuilder(cycles: 2) { cpu in
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
        },
        /// SWAP r
        0x31: InstructionBuilder(cycles: 2) { cpu in
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
        },
        /// SWAP r
        0x32: InstructionBuilder(cycles: 2) { cpu in
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
        },
        /// SWAP r
        0x33: InstructionBuilder(cycles: 2) { cpu in
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
        },
        /// SWAP r
        0x34: InstructionBuilder(cycles: 2) { cpu in
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
        },
        /// SWAP r
        0x35: InstructionBuilder(cycles: 2) { cpu in
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
        },
        /// SWAP HL
        0x36: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let highNibbles = (value & 0xF0) >> 4
            let lowNibbles = (value & 0x0F) << 4
            let swappedValue = lowNibbles | highNibbles
            cpu.writeValue(swappedValue, toMemoryAt: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(swappedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(false)
            )
        },
        /// SWAP r
        0x37: InstructionBuilder(cycles: 2) { cpu in
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
        },
        /// SRL r
        0x38: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerBC.hi.bit(0)
            let shiftedValue = cpu.registerBC.hi >> 1
            cpu.registerBC.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
        },
        /// SRL r
        0x39: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerBC.lo.bit(0)
            let shiftedValue = cpu.registerBC.lo >> 1
            cpu.registerBC.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
        },
        /// SRL r
        0x3A: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerDE.hi.bit(0)
            let shiftedValue = cpu.registerDE.hi >> 1
            cpu.registerDE.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
        },
        /// SRL r
        0x3B: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerDE.lo.bit(0)
            let shiftedValue = cpu.registerDE.lo >> 1
            cpu.registerDE.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
        },
        /// SRL r
        0x3C: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerHL.hi.bit(0)
            let shiftedValue = cpu.registerHL.hi >> 1
            cpu.registerHL.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
        },
        /// SRL r
        0x3D: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerHL.lo.bit(0)
            let shiftedValue = cpu.registerHL.lo >> 1
            cpu.registerHL.lo = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
        },
        /// SRL HL
        0x3E: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let bit0 = value.bit(0)
            let shiftedValue = value >> 1
            cpu.writeValue(shiftedValue, toMemoryAt: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
        },
        /// SRL r
        0x3F: InstructionBuilder(cycles: 2) { cpu in
            let bit0 = cpu.registerAF.hi.bit(0)
            let shiftedValue = cpu.registerAF.hi >> 1
            cpu.registerAF.hi = shiftedValue
            let flag = ALU.Flag(
                zero: .some(shiftedValue == 0),
                subtract: .some(false),
                halfCarry: .some(false),
                carry: .some(bit0)
            )
        },
        /// BIT b, r
        0x40: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x41: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x42: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x43: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x44: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x45: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, (HL)
        0x46: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x47: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 0, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x48: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x49: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x4A: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x4B: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x4C: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x4D: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, (HL)
        0x4E: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x4F: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 1, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x50: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x51: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x52: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x53: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x54: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x55: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, (HL)
        0x56: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x57: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 2, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x58: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x59: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x5A: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x5B: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x5C: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x5D: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, (HL)
        0x5E: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x5F: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 3, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x60: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x61: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x62: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x63: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x64: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x65: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, (HL)
        0x66: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x67: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 4, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x68: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x69: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x6A: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x6B: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x6C: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x6D: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, (HL)
        0x6E: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x6F: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 5, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x70: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x71: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x72: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x73: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x74: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x75: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, (HL)
        0x76: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x77: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 6, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x78: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x79: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerBC.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x7A: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x7B: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerDE.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x7C: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x7D: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerHL.lo.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, (HL)
        0x7E: InstructionBuilder(cycles: 3) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all)
            let flag = ALU.Flag(
                zero: .some(value.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// BIT b, r
        0x7F: InstructionBuilder(cycles: 2) { cpu in
            let flag = ALU.Flag(
                zero: .some(cpu.registerAF.hi.checkBit(at: 7, equalTo: 0)),
                subtract: .some(false),
                halfCarry: .some(true),
                carry: .noneAffected
            )
            cpu.updateFlagFromAluResult(flag)
        },
        /// RES b, r
        0x80: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 0, to: 0)
        },
        /// RES b, r
        0x81: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 0, to: 0)
        },
        /// RES b, r
        0x82: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 0, to: 0)
        },
        /// RES b, r
        0x83: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 0, to: 0)
        },
        /// RES b, r
        0x84: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 0, to: 0)
        },
        /// RES b, r
        0x85: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 0, to: 0)
        },
        /// RES b, HL
        0x86: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 0, to: 0)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0x87: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 0, to: 0)
        },
        /// RES b, r
        0x88: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 1, to: 0)
        },
        /// RES b, r
        0x89: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 1, to: 0)
        },
        /// RES b, r
        0x8A: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 1, to: 0)
        },
        /// RES b, r
        0x8B: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 1, to: 0)
        },
        /// RES b, r
        0x8C: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 1, to: 0)
        },
        /// RES b, r
        0x8D: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 1, to: 0)
        },
        /// RES b, HL
        0x8E: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 1, to: 0)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0x8F: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 1, to: 0)
        },
        /// RES b, r
        0x90: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 2, to: 0)
        },
        /// RES b, r
        0x91: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 2, to: 0)
        },
        /// RES b, r
        0x92: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 2, to: 0)
        },
        /// RES b, r
        0x93: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 2, to: 0)
        },
        /// RES b, r
        0x94: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 2, to: 0)
        },
        /// RES b, r
        0x95: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 2, to: 0)
        },
        /// RES b, HL
        0x96: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 2, to: 0)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0x97: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 2, to: 0)
        },
        /// RES b, r
        0x98: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 3, to: 0)
        },
        /// RES b, r
        0x99: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 3, to: 0)
        },
        /// RES b, r
        0x9A: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 3, to: 0)
        },
        /// RES b, r
        0x9B: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 3, to: 0)
        },
        /// RES b, r
        0x9C: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 3, to: 0)
        },
        /// RES b, r
        0x9D: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 3, to: 0)
        },
        /// RES b, HL
        0x9E: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 3, to: 0)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0x9F: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 3, to: 0)
        },
        /// RES b, r
        0xA0: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA1: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA2: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA3: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA4: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA5: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 4, to: 0)
        },
        /// RES b, HL
        0xA6: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 4, to: 0)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xA7: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 4, to: 0)
        },
        /// RES b, r
        0xA8: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 5, to: 0)
        },
        /// RES b, r
        0xA9: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 5, to: 0)
        },
        /// RES b, r
        0xAA: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 5, to: 0)
        },
        /// RES b, r
        0xAB: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 5, to: 0)
        },
        /// RES b, r
        0xAC: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 5, to: 0)
        },
        /// RES b, r
        0xAD: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 5, to: 0)
        },
        /// RES b, HL
        0xAE: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 5, to: 0)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xAF: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 5, to: 0)
        },
        /// RES b, r
        0xB0: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB1: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB2: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB3: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB4: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB5: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 6, to: 0)
        },
        /// RES b, HL
        0xB6: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 6, to: 0)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xB7: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 6, to: 0)
        },
        /// RES b, r
        0xB8: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 7, to: 0)
        },
        /// RES b, r
        0xB9: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 7, to: 0)
        },
        /// RES b, r
        0xBA: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 7, to: 0)
        },
        /// RES b, r
        0xBB: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 7, to: 0)
        },
        /// RES b, r
        0xBC: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 7, to: 0)
        },
        /// RES b, r
        0xBD: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 7, to: 0)
        },
        /// RES b, HL
        0xBE: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 7, to: 0)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xBF: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 7, to: 0)
        },
        /// RES b, r
        0xC0: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC1: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC2: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC3: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC4: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC5: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 0, to: 1)
        },
        /// RES b, HL
        0xC6: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 0, to: 1)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xC7: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 0, to: 1)
        },
        /// RES b, r
        0xC8: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 1, to: 1)
        },
        /// RES b, r
        0xC9: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 1, to: 1)
        },
        /// RES b, r
        0xCA: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 1, to: 1)
        },
        /// RES b, r
        0xCB: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 1, to: 1)
        },
        /// RES b, r
        0xCC: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 1, to: 1)
        },
        /// RES b, r
        0xCD: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 1, to: 1)
        },
        /// RES b, HL
        0xCE: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 1, to: 1)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xCF: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 1, to: 1)
        },
        /// RES b, r
        0xD0: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD1: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD2: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD3: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD4: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD5: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 2, to: 1)
        },
        /// RES b, HL
        0xD6: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 2, to: 1)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xD7: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 2, to: 1)
        },
        /// RES b, r
        0xD8: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 3, to: 1)
        },
        /// RES b, r
        0xD9: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 3, to: 1)
        },
        /// RES b, r
        0xDA: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 3, to: 1)
        },
        /// RES b, r
        0xDB: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 3, to: 1)
        },
        /// RES b, r
        0xDC: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 3, to: 1)
        },
        /// RES b, r
        0xDD: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 3, to: 1)
        },
        /// RES b, HL
        0xDE: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 3, to: 1)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xDF: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 3, to: 1)
        },
        /// RES b, r
        0xE0: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE1: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE2: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE3: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE4: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE5: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 4, to: 1)
        },
        /// RES b, HL
        0xE6: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 4, to: 1)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xE7: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 4, to: 1)
        },
        /// RES b, r
        0xE8: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 5, to: 1)
        },
        /// RES b, r
        0xE9: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 5, to: 1)
        },
        /// RES b, r
        0xEA: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 5, to: 1)
        },
        /// RES b, r
        0xEB: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 5, to: 1)
        },
        /// RES b, r
        0xEC: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 5, to: 1)
        },
        /// RES b, r
        0xED: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 5, to: 1)
        },
        /// RES b, HL
        0xEE: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 5, to: 1)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xEF: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 5, to: 1)
        },
        /// RES b, r
        0xF0: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF1: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF2: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF3: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF4: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF5: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 6, to: 1)
        },
        /// RES b, HL
        0xF6: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 6, to: 1)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xF7: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 6, to: 1)
        },
        /// RES b, r
        0xF8: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.hi = cpu.registerBC.hi.setBit(at: 7, to: 1)
        },
        /// RES b, r
        0xF9: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerBC.lo = cpu.registerBC.lo.setBit(at: 7, to: 1)
        },
        /// RES b, r
        0xFA: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.hi = cpu.registerDE.hi.setBit(at: 7, to: 1)
        },
        /// RES b, r
        0xFB: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerDE.lo = cpu.registerDE.lo.setBit(at: 7, to: 1)
        },
        /// RES b, r
        0xFC: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.hi = cpu.registerHL.hi.setBit(at: 7, to: 1)
        },
        /// RES b, r
        0xFD: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerHL.lo = cpu.registerHL.lo.setBit(at: 7, to: 1)
        },
        /// RES b, HL
        0xFE: InstructionBuilder(cycles: 4) { cpu in
            let value = cpu.memory(at: cpu.registerHL.all).setBit(at: 7, to: 1)
            cpu.writeValue(value, toMemoryAt: cpu.registerHL.all)
        },
        /// RES b, r
        0xFF: InstructionBuilder(cycles: 2) { cpu in
            cpu.registerAF.hi = cpu.registerAF.hi.setBit(at: 7, to: 1)
        },
    ]
}
