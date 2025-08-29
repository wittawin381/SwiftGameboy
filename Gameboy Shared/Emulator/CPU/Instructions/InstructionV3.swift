////
////  InstructionV3.swift
////  Gameboy
////
////  Created by Wittawin Muangnoi on 3/9/2568 BE.
////
//
//import Foundation
//
//enum InstructionV3 {
//    // MARK: - 0x00
//    /// NOP
//    static func opcode00(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        /// Do Nothing
//    }
//    /// LD rr 16 bit
//    static func opcode01(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        
//        
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//        cpu.registerBC.all = value
//    }
//    /// LD (BC), A
//    static func opcode02(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = cpu.registerAF.hi
//        
//        writeMemory(&cpu, value, cpu.registerBC.all)
//    }
//    /// INC rr
//    static func opcode03(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.all &+= 1
//    }
//    /// INC r
//    static func opcode04(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.increment(cpu.registerBC.hi)
//        cpu.registerBC.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// DEC r
//    static func opcode05(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.decrement(cpu.registerBC.hi)
//        cpu.registerBC.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// LDrn Load to 8 bit register r, the data n
//    static func opcode06(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.hi = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//    }
//    /// RLCA
//    static func opcode07(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let bit7 = cpu.registerAF.hi.bit(7)
//        let shiftedValue = (cpu.registerAF.hi << 1) | bit7.toUInt8()
//        cpu.registerAF.hi = shiftedValue
//        let flag = ALU.Flag(
//            zero: .some(false),
//            subtract: .some(false),
//            halfCarry: .some(false),
//            carry: .some(bit7)
//        )
//        cpu.updateFlag(flag)
//    }
//    /// LD (nn), SP
//    static func opcode08(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantAddressByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantAddressByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let address = (UInt16(mostSignificantAddressByte) << 8) | UInt16(leastSignificantAddressByte)
//        
//        let leastSignificantDataByte = UInt8(cpu.stackPointer & 0xFF)
//        writeMemory(&cpu, leastSignificantDataByte, address)
//        
//        let mostSignificantDataByte = UInt8(cpu.stackPointer >> 8)
//        writeMemory(&cpu, mostSignificantDataByte, address + 1)
//    }
//    /// ADD HL
//    static func opcode09(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add16(cpu.registerHL.all, cpu.registerBC.all, carryBit: 11)
//        cpu.registerHL.all = result.value
//        cpu.updateFlag(
//            ALU.Flag(
//                zero: .noneAffected,
//                subtract: result.flag.subtract,
//                halfCarry: result.flag.halfCarry,
//                carry: result.flag.carry
//            )
//        )
//    }
//    /// LD A, (BC) Load to the 8-bit A register, data from the absolute address specified by the 16-bit register BC.
//    static func opcode0A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = readMemory(cpu, cpu.registerBC.all)
//    }
//    /// DEC rr
//    static func opcode0B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.all &-= 1
//    }
//    /// INC r
//    static func opcode0C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.increment(cpu.registerBC.lo)
//        cpu.registerBC.lo = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// DEC r
//    static func opcode0D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.decrement(cpu.registerBC.lo)
//        cpu.registerBC.lo = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// LDrn Load to 8 bit register r, the data n
//    static func opcode0E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.lo = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//    }
//    /// RRCA
//    static func opcode0F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let bit0 = cpu.registerAF.hi.bit(0)
//        let shiftedValue = (bit0.toUInt8() << 7) | (cpu.registerAF.hi >> 1)
//        cpu.registerAF.hi = shiftedValue
//        let flag = ALU.Flag(
//            zero: .some(false),
//            subtract: .some(false),
//            halfCarry: .some(false),
//            carry: .some(bit0)
//        )
//        cpu.updateFlag(flag)
//    }
//    
//    // MARK: - 0x01
//    /// LD rr 16 bit
//    /// TODO: - correctly implement STOP
//    static func opcode10(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.programCounter += 1
//    }
//    /// LD rr 16 bit
//    static func opcode11(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//        cpu.registerDE.all = value
//    }
//    /// LD (DE), A
//    static func opcode12(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = cpu.registerAF.hi
//        writeMemory(&cpu, value, cpu.registerDE.all)
//    }
//    /// INC rr
//    static func opcode13(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.all &+= 1
//    }
//    /// INC r
//    static func opcode14(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.increment(cpu.registerDE.hi)
//        cpu.registerDE.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// DEC r
//    static func opcode15(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.decrement(cpu.registerDE.hi)
//        cpu.registerDE.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// LDrn Load to 8 bit register r, the data n
//    static func opcode16(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.hi = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//    }
//    /// RLA
//    static func opcode17(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let carry = cpu.carryFlag.toUInt8()
//        let bit7 = cpu.registerAF.hi.bit(7)
//        let shiftedValue = (cpu.registerAF.hi << 1) | carry
//        cpu.registerAF.hi = shiftedValue
//        let flag = ALU.Flag(
//            zero: .some(false),
//            subtract: .some(false),
//            halfCarry: .some(false),
//            carry: .some(bit7)
//        )
//        cpu.updateFlag(flag)
//    }
//    /// JR e
//    static func opcode18(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let signedValue = Int16(Int8(bitPattern: value))
//        let programCounter = Int16(bitPattern: cpu.programCounter)
//        let address = programCounter + signedValue
//        cpu.programCounter = UInt16(bitPattern: address)
//    }
//    /// ADD HL
//    static func opcode19(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add16(cpu.registerHL.all, cpu.registerDE.all, carryBit: 11)
//        cpu.registerHL.all = result.value
//        cpu.updateFlag(
//            ALU.Flag(
//                zero: .noneAffected,
//                subtract: result.flag.subtract,
//                halfCarry: result.flag.halfCarry,
//                carry: result.flag.carry
//            )
//        )
//    }
//    /// LD A, (BC) Load to the 8-bit A register, data from the absolute address specified by the 16-bit register BC.
//    static func opcode1A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.registerDE.all)
//        cpu.registerAF.hi = value
//    }
//    /// DEC rr
//    static func opcode1B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.all &-= 1
//    }
//    /// INC r
//    static func opcode1C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.increment(cpu.registerDE.lo)
//        cpu.registerDE.lo = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// DEC r
//    static func opcode1D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.decrement(cpu.registerDE.lo)
//        cpu.registerDE.lo = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// LDrn Load to 8 bit register r, the data n
//    static func opcode1E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.lo = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//    }
//    /// RRA
//    static func opcode1F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let carry = cpu.carryFlag.toUInt8()
//        let bit0 = cpu.registerAF.hi.bit(0)
//        let shiftedValue = (cpu.registerAF.hi >> 1) | (carry << 7)
//        cpu.registerAF.hi = shiftedValue
//        let flag = ALU.Flag(
//            zero: .some(false),
//            subtract: .some(false),
//            halfCarry: .some(false),
//            carry: .some(bit0)
//        )
//        cpu.updateFlag(flag)
//    }
//    
//    // MARK: - 0x02
//    /// JR cc, e
//    static func opcode20(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
////    0x20: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        if !cpu.zeroFlag {
//            return InstructionV2(cycles: 3) { cpu, readMemory, writeMemory in
//                let value = readMemory(cpu, cpu.programCounter)
//                cpu.programCounter += 1
//                let signedValue = Int8(bitPattern: value)
//                cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
//            }
//        } else {
//            return InstructionV2(cycles: 2) { cpu, readMemory, writeMemory in
//                let _ = readMemory(cpu, cpu.programCounter)
//                cpu.programCounter += 1
//            }
//        }
//    }
//    /// LD HL rr 16 bit
//    static func opcode21(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//        cpu.registerHL.all = value
//    }
//    /// LD (HL+), A
//    static func opcode22(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let address = cpu.registerHL.all
//        writeMemory(&cpu, cpu.registerAF.hi, address)
//        cpu.registerHL.all &+= 1
//    }
//    /// INC rr
//    static func opcode23(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.all &+= 1
//    }
//    /// INC r
//    static func opcode24(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.increment(cpu.registerHL.hi)
//        cpu.registerHL.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// DEC r
//    static func opcode25(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.decrement(cpu.registerHL.hi)
//        cpu.registerHL.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// LDrn Load to 8 bit register r, the data n
//    static func opcode26(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.hi = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//    }
//    /// DAA
//    static func opcode27(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        //TODO: - Implement DAA Instruction
//    }
//    /// JR cc, e
//    0x28: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        if cpu.zeroFlag {
//            return InstructionV2(cycles: 3) { cpu, readMemory, writeMemory in
//                let value = readMemory(cpu, cpu.programCounter)
//                cpu.programCounter += 1
//                let signedValue = Int8(bitPattern: value)
//                cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
//            }
//        } else {
//            return InstructionV2(cycles: 2) { cpu, readMemory, writeMemory in
//                let _ = readMemory(cpu, cpu.programCounter)
//                cpu.programCounter += 1
//            }
//        }
//    }
//    /// ADD HL
//    static func opcode29(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add16(cpu.registerHL.all, cpu.registerHL.all, carryBit: 11)
//        cpu.registerHL.all = result.value
//        cpu.updateFlag(
//            ALU.Flag(
//                zero: .noneAffected,
//                subtract: result.flag.subtract,
//                halfCarry: result.flag.halfCarry,
//                carry: result.flag.carry
//            )
//        )
//    }
//    /// LD A, (HL+)
//    static func opcode2A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let address = cpu.registerHL.all
//        cpu.registerAF.hi = readMemory(cpu, address)
//        cpu.registerHL.all += 1
//    }
//    /// DEC rr
//    static func opcode2B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.all &-= 1
//    }
//    /// INC r
//    static func opcode2C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.increment(cpu.registerHL.lo)
//        cpu.registerHL.lo = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// DEC r
//    static func opcode2D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.decrement(cpu.registerHL.lo)
//        cpu.registerHL.lo = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// LDrn Load to 8 bit register r, the data n
//    static func opcode2E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.lo = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//    }
//    /// LDrn Load to 8 bit register r, the data n
//    static func opcode2F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = ~cpu.registerAF.hi
//        let flag = ALU.Flag(
//            zero: .noneAffected,
//            subtract: .some(true),
//            halfCarry: .some(true),
//            carry: .noneAffected
//        )
//        cpu.updateFlag(flag)
//    }
//    
//    // MARK: - 0x03
//    /// JR cc, e
//    0x30: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        if !cpu.carryFlag {
//            return InstructionV2(cycles: 3) { cpu, readMemory, writeMemory in
//                let value = readMemory(cpu, cpu.programCounter)
//                cpu.programCounter += 1
//                let signedValue = Int8(bitPattern: value)
//                cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
//            }
//        } else {
//            return InstructionV2(cycles: 2) { cpu, readMemory, writeMemory in
//                let _ = readMemory(cpu, cpu.programCounter)
//                cpu.programCounter += 1
//            }
//        }
//    }
//    /// LD rr 16 bit
//    static func opcode31(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte: UInt8 = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let value = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//        cpu.stackPointer = value
//    }
//    /// LD (HL-), A
//    static func opcode32(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let address = cpu.registerHL.all
//        writeMemory(&cpu, cpu.registerAF.hi, address)
//        cpu.registerHL.all &-= 1
//    }
//    /// INC rr
//    static func opcode33(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer &+= 1
//    }
//    /// INC HL
//    static func opcode34(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.increment(readMemory(cpu, cpu.registerHL.all))
//        writeMemory(&cpu, result.value, cpu.registerHL.all)
//        cpu.updateFlag(result.flag)
//    }
//    /// DEC HL
//    static func opcode35(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.decrement(readMemory(cpu, cpu.registerHL.all))
//        writeMemory(&cpu, result.value, cpu.registerHL.all)
//        cpu.updateFlag(result.flag)
//    }
//    /// LD (HL)
//    static func opcode36(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        writeMemory(&cpu, value, cpu.registerHL.all)
//    }
//    /// SCF
//    static func opcode37(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let flag = ALU.Flag(
//            zero: .noneAffected,
//            subtract: .some(false),
//            halfCarry: .some(false),
//            carry: .some(true)
//        )
//        cpu.updateFlag(flag)
//    }
//    /// JR cc, e
//    0x38: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        if cpu.carryFlag {
//            return InstructionV2(cycles: 3) { cpu, readMemory, writeMemory in
//                let signedValue = Int8(bitPattern: value)
//                cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
//            }
//        } else {
//            return InstructionV2(cycles: 2) { _, _, _ in }
//        }
//    }
//    /// ADD HL
//    static func opcode39(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add16(cpu.registerHL.all, cpu.stackPointer, carryBit: 11)
//        cpu.registerHL.all = result.value
//        cpu.updateFlag(
//            ALU.Flag(
//                zero: .noneAffected,
//                subtract: result.flag.subtract,
//                halfCarry: result.flag.halfCarry,
//                carry: result.flag.carry
//            )
//        )
//    }
//    /// LD A, (HL-)
//    static func opcode3A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let address = cpu.registerHL.all
//        cpu.registerAF.hi = readMemory(cpu, address)
//        cpu.registerHL.all -= 1
//    }
//    /// DEC rr
//    static func opcode3B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer &-= 1
//    }
//    /// INC r
//    static func opcode3C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.increment(cpu.registerAF.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// DEC r
//    static func opcode3D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.decrement(cpu.registerAF.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// LDrn Load to 8 bit register r, the data n
//    static func opcode3E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//    }
//    /// CCF
//    static func opcode3F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let flag = ALU.Flag(
//            zero: .noneAffected,
//            subtract: .some(false),
//            halfCarry: .some(false),
//            carry: .some(!cpu.carryFlag)
//        )
//        cpu.updateFlag(flag)
//    }
//    
//    // MARK: - 0x40
//    /// LDrr` Load to 8 bit register r, from 8-bit register r`
//    static func opcode40(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.hi = cpu.registerBC.hi
//    }
//    /// LDrr`
//    static func opcode41(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.hi = cpu.registerBC.lo
//    }
//    /// LDrr`
//    static func opcode42(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.hi = cpu.registerDE.hi
//    }
//    /// LDrr`
//    static func opcode43(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.hi = cpu.registerDE.lo
//    }
//    /// LDrr`
//    static func opcode44(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.hi = cpu.registerHL.hi
//    }
//    /// LDrr`
//    static func opcode45(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.hi = cpu.registerHL.lo
//    }
//    /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
//    static func opcode46(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.hi = readMemory(cpu, cpu.registerHL.all)
//    }
//    /// LDrr`
//    static func opcode47(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.hi = cpu.registerAF.hi
//    }
//    /// LDrr`
//    static func opcode48(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.lo = cpu.registerBC.hi
//    }
//    /// LDrr`
//    static func opcode49(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.lo = cpu.registerBC.lo
//    }
//    /// LDrr`
//    static func opcode4A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.lo = cpu.registerDE.hi
//    }
//    /// LDrr`
//    static func opcode4B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.lo = cpu.registerDE.lo
//    }
//    /// LDrr`
//    static func opcode4C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.lo = cpu.registerHL.hi
//    }
//    /// LDrr`
//    static func opcode4D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.lo = cpu.registerHL.lo
//    }
//    /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
//    static func opcode4E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.lo = readMemory(cpu, cpu.registerHL.all)
//    }
//    /// LDrr`
//    static func opcode4F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerBC.lo = cpu.registerAF.hi
//    }
//    // MARK: - 0x50
//    /// LDrr` Load to 8 bit register r, from 8-bit register r`
//    static func opcode50(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.hi = cpu.registerBC.hi
//    }
//    /// LDrr`
//    static func opcode51(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.hi = cpu.registerBC.lo
//    }
//    /// LDrr`
//    static func opcode52(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.hi = cpu.registerDE.hi
//    }
//    /// LDrr`
//    static func opcode53(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.hi = cpu.registerDE.lo
//    }
//    /// LDrr`
//    static func opcode54(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.hi = cpu.registerHL.hi
//    }
//    /// LDrr`
//    static func opcode55(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.hi = cpu.registerHL.lo
//    }
//    /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
//    static func opcode56(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.hi = readMemory(cpu, cpu.registerHL.all)
//    }
//    /// LDrr`
//    static func opcode57(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.hi = cpu.registerAF.hi
//    }
//    /// LDrr`
//    static func opcode58(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.lo = cpu.registerBC.hi
//    }
//    /// LDrr`
//    static func opcode59(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.lo = cpu.registerBC.lo
//    }
//    /// LDrr`
//    static func opcode5A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.lo = cpu.registerDE.hi
//    }
//    /// LDrr`
//    static func opcode5B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.lo = cpu.registerDE.lo
//    }
//    /// LDrr`
//    static func opcode5C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.lo = cpu.registerHL.hi
//    }
//    /// LDrr`
//    static func opcode5D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.lo = cpu.registerHL.lo
//    }
//    /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
//    static func opcode5E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.lo = readMemory(cpu, cpu.registerHL.all)
//    }
//    /// LDrr`
//    static func opcode5F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerDE.lo = cpu.registerAF.hi
//    }
//    
//    // MARK: - 0x60
//    /// LDrr` Load to 8 bit register r, from 8-bit register r`
//    static func opcode60(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.hi = cpu.registerBC.hi
//    }
//    /// LDrr`
//    static func opcode61(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.hi = cpu.registerBC.lo
//    }
//    /// LDrr`
//    static func opcode62(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.hi = cpu.registerDE.hi
//    }
//    /// LDrr`
//    static func opcode63(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.hi = cpu.registerDE.lo
//    }
//    /// LDrr`
//    static func opcode64(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.hi = cpu.registerHL.hi
//    }
//    /// LDrr`
//    static func opcode65(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.hi = cpu.registerHL.lo
//    }
//    /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
//    static func opcode66(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.hi = readMemory(cpu, cpu.registerHL.all)
//    }
//    /// LDrr`
//    static func opcode67(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.hi = cpu.registerAF.hi
//    }
//    /// LDrr`
//    static func opcode68(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.lo = cpu.registerBC.hi
//    }
//    /// LDrr`
//    static func opcode69(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.lo = cpu.registerBC.lo
//    }
//    /// LDrr`
//    static func opcode6A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.lo = cpu.registerDE.hi
//    }
//    /// LDrr`
//    static func opcode6B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.lo = cpu.registerDE.lo
//    }
//    /// LDrr`
//    static func opcode6C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.lo = cpu.registerHL.hi
//    }
//    /// LDrr`
//    static func opcode6D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.lo = cpu.registerHL.lo
//    }
//    /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
//    static func opcode6E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.lo = readMemory(cpu, cpu.registerHL.all)
//    }
//    /// LDrr`
//    static func opcode6F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerHL.lo = cpu.registerAF.hi
//    }
//    
//    // MARK: - 0x70
//    //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
//    static func opcode70(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        writeMemory(&cpu, cpu.registerBC.hi, cpu.registerHL.all)
//    }
//    //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
//    static func opcode71(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        writeMemory(&cpu, cpu.registerBC.lo, cpu.registerHL.all)
//    }
//    //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
//    static func opcode72(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        writeMemory(&cpu, cpu.registerDE.hi, cpu.registerHL.all)
//    }
//    //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
//    static func opcode73(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        writeMemory(&cpu, cpu.registerDE.lo, cpu.registerHL.all)
//    }
//    //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
//    static func opcode74(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        writeMemory(&cpu, cpu.registerHL.hi, cpu.registerHL.all)
//    }
//    //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
//    static func opcode75(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        writeMemory(&cpu, cpu.registerHL.lo, cpu.registerHL.all)
//    }
//    /// TODO: implement correct HALT instruction
//    static func opcode76(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.isHalted = true
//    }
//    //LD (HL), r Load to the absolute address specified by the 16-bit register HL, data from the 8-bit register r.
//    static func opcode77(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        writeMemory(&cpu, cpu.registerAF.hi, cpu.registerHL.all)
//    }
//    /// LDrr`
//    static func opcode78(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = cpu.registerBC.hi
//    }
//    /// LDrr`
//    static func opcode79(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = cpu.registerBC.lo
//    }
//    /// LDrr`
//    static func opcode7A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = cpu.registerDE.hi
//    }
//    /// LDrr`
//    static func opcode7B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = cpu.registerDE.lo
//    }
//    /// LDrr`
//    static func opcode7C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = cpu.registerHL.hi
//    }
//    /// LDrr`
//    static func opcode7D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = cpu.registerHL.lo
//    }
//    /// LD r, (HL) Load to the 8-bit register r, data from the absolute address specified by the 16-bit register HL.
//    static func opcode7E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = readMemory(cpu, cpu.registerHL.all)
//    }
//    /// LDrr`
//    static func opcode7F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.registerAF.hi = cpu.registerAF.hi
//    }
//    
//    // MARK: - 0x80
//    /// ADD r
//    static func opcode80(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADD r
//    static func opcode81(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADD r
//    static func opcode82(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADD r
//    static func opcode83(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADD r
//    static func opcode84(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADD r
//    static func opcode85(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADD r
//    static func opcode86(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.registerHL.all)
//        let result = ALU.add(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADD r
//    static func opcode87(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerAF.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADC r
//    static func opcode88(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.hi, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADC r
//    static func opcode89(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerBC.lo, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADC r
//    static func opcode8A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.hi, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADC r
//    static func opcode8B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerDE.lo, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADC r
//    static func opcode8C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.hi, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADC r
//    static func opcode8D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerHL.lo, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADC (HL)
//    static func opcode8E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.registerHL.all)
//        let result = ALU.add(cpu.registerAF.hi, value, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// ADC r
//    static func opcode8F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.add(cpu.registerAF.hi, cpu.registerAF.hi, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    
//    // MARK: - 0x90
//    /// SUB r
//    static func opcode90(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SUB r
//    static func opcode91(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SUB r
//    static func opcode92(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SUB r
//    static func opcode93(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SUB r
//    static func opcode94(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SUB r
//    static func opcode95(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SUB r
//    static func opcode96(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.registerHL.all)
//        let result = ALU.sub(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SUB r
//    static func opcode97(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SBC r
//    static func opcode98(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SBC r
//    static func opcode99(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SBC r
//    static func opcode9A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SBC r
//    static func opcode9B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SBC r
//    static func opcode9C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SBC r
//    static func opcode9D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SBC HL
//    static func opcode9E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.registerHL.all)
//        let result = ALU.sub(cpu.registerAF.hi, value, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// SBC r
//    static func opcode9F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    // MARK: - 0xA0
//    /// AND r
//    static func opcodeA0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.and(cpu.registerAF.hi, cpu.registerBC.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// AND r
//    static func opcodeA1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.and(cpu.registerAF.hi, cpu.registerBC.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// AND r
//    static func opcodeA2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.and(cpu.registerAF.hi, cpu.registerDE.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// AND r
//    static func opcodeA3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.and(cpu.registerAF.hi, cpu.registerDE.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// AND r
//    static func opcodeA4(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.and(cpu.registerAF.hi, cpu.registerHL.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// AND r
//    static func opcodeA5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.and(cpu.registerAF.hi, cpu.registerHL.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// AND HL
//    static func opcodeA6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.registerHL.all)
//        let result = ALU.and(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// AND r
//    static func opcodeA7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.and(cpu.registerAF.hi, cpu.registerAF.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// XOR r
//    static func opcodeA8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.xor(cpu.registerAF.hi, cpu.registerBC.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// XOR r
//    static func opcodeA9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.xor(cpu.registerAF.hi, cpu.registerBC.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// XOR r
//    static func opcodeAA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.xor(cpu.registerAF.hi, cpu.registerDE.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// XOR r
//    static func opcodeAB(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.xor(cpu.registerAF.hi, cpu.registerDE.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// XOR r
//    static func opcodeAC(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.xor(cpu.registerAF.hi, cpu.registerHL.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// XOR r
//    static func opcodeAD(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.xor(cpu.registerAF.hi, cpu.registerHL.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// XOR HL
//    static func opcodeAE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.registerHL.all)
//        let result = ALU.xor(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// XOR r
//    static func opcodeAF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.xor(cpu.registerAF.hi, cpu.registerAF.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    
//    // MARK: - 0xB0
//    /// OR r
//    static func opcodeB0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.or(cpu.registerAF.hi, cpu.registerBC.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// OR r
//    static func opcodeB1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.or(cpu.registerAF.hi, cpu.registerBC.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// OR r
//    static func opcodeB2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.or(cpu.registerAF.hi, cpu.registerDE.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// OR r
//    static func opcodeB3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.or(cpu.registerAF.hi, cpu.registerDE.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// OR r
//    static func opcodeB4(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.or(cpu.registerAF.hi, cpu.registerHL.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// OR r
//    static func opcodeB5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.or(cpu.registerAF.hi, cpu.registerHL.lo)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// OR HL
//    static func opcodeB6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.registerHL.all)
//        let result = ALU.or(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    /// OR r
//    static func opcodeB7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.or(cpu.registerAF.hi, cpu.registerAF.hi)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    
//    /// CP r
//    static func opcodeB8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.hi)
//        cpu.updateFlag(result.flag)
//    }
//    /// CP r
//    static func opcodeB9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerBC.lo)
//        cpu.updateFlag(result.flag)
//    }
//    /// CP r
//    static func opcodeBA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.hi)
//        cpu.updateFlag(result.flag)
//    }
//    /// CP r
//    static func opcodeBB(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerDE.lo)
//        cpu.updateFlag(result.flag)
//    }
//    /// CP r
//    static func opcodeBC(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.hi)
//        cpu.updateFlag(result.flag)
//    }
//    /// CP r
//    static func opcodeBD(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerHL.lo)
//        cpu.updateFlag(result.flag)
//    }
//    /// CP HL
//    static func opcodeBE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.registerHL.all)
//        let result = ALU.sub(cpu.registerAF.hi, value)
//        cpu.updateFlag(result.flag)
//    }
//    /// CP r
//    static func opcodeBF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let result = ALU.sub(cpu.registerAF.hi, cpu.registerAF.hi)
//        cpu.updateFlag(result.flag)
//    }
//    
//    // MARK: - 0xC0
//    /// RET CC
//    0xC0: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        if !cpu.zeroFlag {
//            return InstructionV2(cycles: 5) { cpu, readMemory, writeMemory in
//                let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//                cpu.stackPointer += 1
//                let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//                cpu.stackPointer += 1
//                cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//            }
//        } else {
//            return InstructionV2(cycles: 2) { _, _, _ in }
//        }
//    }
//    /// POP rr
//    static func opcodeC1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        cpu.registerBC.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//    }
//    /// JP cc, nn
//    0xC2: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        if !cpu.zeroFlag {
//            return InstructionV2(cycles: 4) { cpu, readMemory, writeMemory in
//                let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//                cpu.programCounter = address
//            }
//        } else {
//            return InstructionV2(cycles: 3) { _, _, _ in }
//        }
//    }
//    /// JP nn
//    static func opcodeC3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//        cpu.programCounter = address
//    }
//    /// CALL cc, nn
//    0xC4: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        if !cpu.zeroFlag {
//            return InstructionV2(cycles: 6) { cpu, readMemory, writeMemory in
//                
//                cpu.stackPointer -= 1
//                writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//                cpu.stackPointer -= 1
//                writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//                
//                let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//                cpu.programCounter = address
//            }
//        } else {
//            return InstructionV2(cycles: 3) { _, _, _ in }
//        }
//    }
//    /// PUSH rr
//    static func opcodeC5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, cpu.registerBC.hi, cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, cpu.registerBC.lo, cpu.stackPointer)
//    }
//    /// ADD n
//    static func opcodeC6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let result = ALU.add(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    // RST n RST 00
//    static func opcodeC7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//        cpu.programCounter = 0x0 | 0x0
//    }
//    /// RET CC
//    0xC8: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        if cpu.zeroFlag {
//            return InstructionV2(cycles: 5) { cpu, readMemory, writeMemory in
//                let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//                cpu.stackPointer += 1
//                let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//                cpu.stackPointer += 1
//                cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//            }
//        } else {
//            return InstructionV2(cycles: 2) { _, _, _ in }
//        }
//    }
//    /// RET
//    static func opcodeC9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//    }
//    /// JP cc, nn
//    0xCA: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        if cpu.zeroFlag {
//            return InstructionV2(cycles: 4) { cpu, readMemory, writeMemory in
//                let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//                cpu.programCounter = address
//            }
//        } else {
//            return InstructionV2(cycles: 3) { _, _, _ in }
//        }
//    }
//    /// PREFIX
//    0xCB: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let opcode = readMemory(cpu, cpu.programCounter)
//        //            print(String(format: "%llx %llx", opcode, cpu.programCounter))
//        cpu.programCounter += 1
//        if let instruction = prefixInstruction[opcode]?.build(&cpu, readMemory, writeMemory) {
//            return instruction
//            //                return InstructionV2(cycles: instruction.cycles + 1, perform: instruction.perform)
//        } else {
//            fatalError("opcode : \(opcode) hasn't been implemented")
//        }
//    }
//    /// CALL cc, nn
//    0xCC: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        if cpu.zeroFlag {
//            return InstructionV2(cycles: 6) { cpu, readMemory, writeMemory in
//                cpu.stackPointer -= 1
//                writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//                cpu.stackPointer -= 1
//                writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//                
//                let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//                cpu.programCounter = address
//            }
//        } else {
//            return InstructionV2(cycles: 3) { _, _, _ in
//            }
//        }
//    }
//    /// CALLCALL nn
//    static func opcodeCD(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//        
//        cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//    }
//    /// ADC n
//    static func opcodeCE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let result = ALU.add(cpu.registerAF.hi, value, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    // RST n RST 0x08
//    static func opcodeCF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//        cpu.programCounter = 0x08
//    }
//    
//    // MARK: - 0xD0
//    /// RET CC
//    0xD0: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        if !cpu.carryFlag {
//            return InstructionV2(cycles: 5) { cpu, readMemory, writeMemory in
//                let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//                cpu.stackPointer += 1
//                let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//                cpu.stackPointer += 1
//                cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//            }
//        } else {
//            return InstructionV2(cycles: 2) { _, _, _ in }
//        }
//    }
//    /// POP rr
//    static func opcodeD1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        cpu.registerDE.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//    }
//    /// JP cc, nn
//    0xD2: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        if !cpu.carryFlag {
//            return InstructionV2(cycles: 4) { cpu, readMemory, writeMemory in
//                let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//                cpu.programCounter = address
//            }
//        } else {
//            return InstructionV2(cycles: 3) { _, _, _ in }
//        }
//    }
//    /// CALL cc, nn
//    0xD4: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        if !cpu.carryFlag {
//            return InstructionV2(cycles: 6) { cpu, readMemory, writeMemory in
//                cpu.stackPointer -= 1
//                writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//                cpu.stackPointer -= 1
//                writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//                
//                let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//                cpu.programCounter = address
//            }
//        } else {
//            return InstructionV2(cycles: 3) { _, _, _ in }
//        }
//    }
//    /// PUSH rr
//    static func opcodeD5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, cpu.registerDE.hi, cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, cpu.registerDE.lo, cpu.stackPointer)
//    }
//    /// SUB n
//    static func opcodeD6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let result = ALU.sub(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    // RST n RST 10
//    static func opcodeD7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//        cpu.programCounter = 0x10
//    }
//    /// RET CC
//    0xD8: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        if cpu.carryFlag {
//            return InstructionV2(cycles: 5) { cpu, readMemory, writeMemory in
//                let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//                cpu.stackPointer += 1
//                let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//                cpu.stackPointer += 1
//                cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//            }
//        } else {
//            return InstructionV2(cycles: 2) { _, _, _ in }
//        }
//    }
//    /// RET CC
//    static func opcodeD9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//        cpu.interruptMasterEnabled = true
//    }
//    /// JP cc, nn
//    0xDA: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        if cpu.carryFlag {
//            return InstructionV2(cycles: 4) { cpu, readMemory, writeMemory in
//                let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//                cpu.programCounter = address
//            }
//        } else {
//            return InstructionV2(cycles: 3) { _, _, _ in }
//        }
//    }
//    /// CALL cc, nn
//    0xDC: InstructionBuilderV2 { cpu, readMemory, writeMemory in
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        if cpu.carryFlag {
//            return InstructionV2(cycles: 6) { cpu, readMemory, writeMemory in
//                cpu.stackPointer -= 1
//                writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//                cpu.stackPointer -= 1
//                writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//                
//                let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//                cpu.programCounter = address
//            }
//        } else {
//            return InstructionV2(cycles: 3) { _, _, _ in }
//        }
//    }
//    /// SBC n
//    static func opcodeDE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let result = ALU.sub(cpu.registerAF.hi, value, carry: cpu.carryFlag)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    // RST n RST 18
//    static func opcodeDF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//        cpu.programCounter = 0x18
//    }
//    
//    // MARK: - 0xE0
//    /// LDH (C), A
//    static func opcodeE0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
//        writeMemory(&cpu, cpu.registerAF.hi, address)
//    }
//    /// POP rr
//    static func opcodeE1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        cpu.registerHL.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//    }
//    /// LDH (C), A
//    static func opcodeE2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = cpu.registerBC.lo
//        let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
//        writeMemory(&cpu, cpu.registerAF.hi, address)
//    }
//    /// PUSH rr
//    static func opcodeE5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, cpu.registerHL.hi, cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, cpu.registerHL.lo, cpu.stackPointer)
//    }
//    /// AND n
//    static func opcodeE6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let result = ALU.and(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    // RST n RST 20
//    static func opcodeE7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//        cpu.programCounter = 0x20
//    }
//    /// ADD SP
//    static func opcodeE8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let signedValue = Int8(bitPattern: value)
//        let halfCarry = ALU.checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 3)
//        let carry = ALU.checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 7)
//        cpu.stackPointer = cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
//        
//        let flag = ALU.Flag(
//            zero: .some(false),
//            subtract: .some(false),
//            halfCarry: .some(halfCarry),
//            carry: .some(carry)
//        )
//        cpu.updateFlag(flag)
//    }
//    /// JP nn
//    static func opcodeE9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.programCounter = cpu.registerHL.all
//    }
//    /// LD (nn), A
//    static func opcodeEA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//        writeMemory(&cpu, cpu.registerAF.hi, address)
//    }
//    /// XOR n
//    static func opcodeEE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let result = ALU.xor(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    // RST n RST 28
//    static func opcodeEF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//        cpu.programCounter = 0x28
//    }
//    
//    // MARK: - 0xF0
//    /// LDH A, (n)
//    static func opcodeF0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
//        let value = readMemory(cpu, address)
//        cpu.registerAF.hi = value
//    }
//    /// POP rr
//    static func opcodeF1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        let mostSignificantByte = readMemory(cpu, cpu.stackPointer)
//        cpu.stackPointer += 1
//        cpu.registerAF.all = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte & 0xF0)
//    }
//    /// LDH  A, (C)
//    static func opcodeF2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = cpu.registerBC.lo
//        let address: UInt16 = 0xFF00 | UInt16(leastSignificantByte)
//        cpu.registerAF.hi = readMemory(cpu, address)
//    }
//    /// DI
//    static func opcodeF3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.interruptMasterEnabled = false
//    }
//    /// PUSH rr
//    static func opcodeF5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, cpu.registerAF.hi, cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, cpu.registerAF.lo, cpu.stackPointer)
//    }
//    /// OR n
//    static func opcodeF6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let result = ALU.or(cpu.registerAF.hi, value)
//        cpu.registerAF.hi = result.value
//        cpu.updateFlag(result.flag)
//    }
//    // RST n RST 30
//    static func opcodeF7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//        cpu.programCounter = 0x30
//    }
//    /// LD HL, SP+e
//    static func opcodeF8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let signedValue = Int8(bitPattern: value)
//        let halfCarry = ALU.checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 3)
//        let carry = ALU.checkCarry(cpu.stackPointer, UInt16(bitPattern: Int16(signedValue)), carryBit: 7)
//        cpu.registerHL.all = cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
//        cpu.updateFlag(
//            ALU.Flag(
//                zero: .some(false),
//                subtract: .some(false),
//                halfCarry: .some(halfCarry),
//                carry: .some(carry)
//            )
//        )
//    }
//    /// LD SP, HL
//    static func opcodeF9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer = cpu.registerHL.all
//    }
//    /// LD A, (nn)
//    static func opcodeFA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let leastSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let mostSignificantByte = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let address: UInt16 = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
//        cpu.registerAF.hi = readMemory(cpu, address)
//    }
//    /// DI
//    static func opcodeFB(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.isInterruptMasterEnabledRequest = true
//    }
//    /// CP n
//    static func opcodeFE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        let value = readMemory(cpu, cpu.programCounter)
//        cpu.programCounter += 1
//        let result = ALU.sub(cpu.registerAF.hi, value)
//        cpu.updateFlag(result.flag)
//    }
//    // RST n RST 38
//    static func opcodeFF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter >> 8), cpu.stackPointer)
//        cpu.stackPointer -= 1
//        writeMemory(&cpu, UInt8(cpu.programCounter & 0xFF), cpu.stackPointer)
//        cpu.programCounter = 0x38
//    }
//    
//        static func prefixOpcode00(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerBC.hi.bit(7)
//            let shiftedValue = (cpu.registerBC.hi << 1) | bit7.toUInt8()
//            cpu.registerBC.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RLC r
//        static func prefixOpcode01(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerBC.lo.bit(7)
//            let shiftedValue = (cpu.registerBC.lo << 1) | bit7.toUInt8()
//            cpu.registerBC.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RLC r
//        static func prefixOpcode02(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerDE.hi.bit(7)
//            let shiftedValue = (cpu.registerDE.hi << 1) | bit7.toUInt8()
//            cpu.registerDE.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RLC r
//        static func prefixOpcode03(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerDE.lo.bit(7)
//            let shiftedValue = (cpu.registerDE.lo << 1) | bit7.toUInt8()
//            cpu.registerDE.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RLC r
//        static func prefixOpcode04(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerHL.hi.bit(7)
//            let shiftedValue = (cpu.registerHL.hi << 1) | bit7.toUInt8()
//            cpu.registerHL.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RLC r
//        static func prefixOpcode05(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerHL.lo.bit(7)
//            let shiftedValue = (cpu.registerHL.lo << 1) | bit7.toUInt8()
//            cpu.registerHL.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RLC HL
//        static func prefixOpcode06(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let bit7 = value.bit(7)
//            let shiftedValue = (value << 1) | bit7.toUInt8()
//            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RLC r
//        static func prefixOpcode07(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerAF.hi.bit(7)
//            let shiftedValue = (cpu.registerAF.hi << 1) | bit7.toUInt8()
//            cpu.registerAF.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode08(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerBC.hi.bit(0)
//            let shiftedValue = (cpu.registerBC.hi >> 1) | (bit0.toUInt8() << 7)
//            cpu.registerBC.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode09(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerBC.lo.bit(0)
//            let shiftedValue = (cpu.registerBC.lo >> 1) | (bit0.toUInt8() << 7)
//            cpu.registerBC.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode0A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerDE.hi.bit(0)
//            let shiftedValue = (cpu.registerDE.hi >> 1) | (bit0.toUInt8() << 7)
//            cpu.registerDE.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode0B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerDE.lo.bit(0)
//            let shiftedValue = (cpu.registerDE.lo >> 1) | (bit0.toUInt8() << 7)
//            cpu.registerDE.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode0C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerHL.hi.bit(0)
//            let shiftedValue = (cpu.registerHL.hi >> 1) | (bit0.toUInt8() << 7)
//            cpu.registerHL.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode0D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerHL.lo.bit(0)
//            let shiftedValue = (cpu.registerHL.lo >> 1) | (bit0.toUInt8() << 7)
//            cpu.registerHL.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC HL
//        static func prefixOpcode0E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let bit0 = value.bit(0)
//            let shiftedValue = (value >> 1) | (bit0.toUInt8() << 7)
//            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode0F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerAF.hi.bit(0)
//            let shiftedValue = (cpu.registerAF.hi >> 1) | (bit0.toUInt8() << 7)
//            cpu.registerAF.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        // MARK: - 0x1
//        /// RRC r
//        static func prefixOpcode10(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit7 = cpu.registerBC.hi.bit(7)
//            let shiftedValue = (cpu.registerBC.hi << 1) | carry
//            cpu.registerBC.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode11(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit7 = cpu.registerBC.lo.bit(7)
//            let shiftedValue = (cpu.registerBC.lo << 1) | carry
//            cpu.registerBC.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode12(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit7 = cpu.registerDE.hi.bit(7)
//            let shiftedValue = (cpu.registerDE.hi << 1) | carry
//            cpu.registerDE.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode13(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit7 = cpu.registerDE.lo.bit(7)
//            let shiftedValue = (cpu.registerDE.lo << 1) | carry
//            cpu.registerDE.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode14(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit7 = cpu.registerHL.hi.bit(7)
//            let shiftedValue = (cpu.registerHL.hi << 1) | carry
//            cpu.registerHL.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode15(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit7 = cpu.registerHL.lo.bit(7)
//            let shiftedValue = (cpu.registerHL.lo << 1) | carry
//            cpu.registerHL.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC HL
//        static func prefixOpcode16(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let carry = cpu.carryFlag.toUInt8()
//            let bit7 = value.bit(7)
//            let shiftedValue = (value << 1) | carry
//            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RRC r
//        static func prefixOpcode17(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit7 = cpu.registerAF.hi.bit(7)
//            let shiftedValue = (cpu.registerAF.hi << 1) | carry
//            cpu.registerAF.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RR r
//        static func prefixOpcode18(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit0 = cpu.registerBC.hi.bit(0)
//            let shiftedValue = (cpu.registerBC.hi >> 1) | (carry << 7)
//            cpu.registerBC.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RR r
//        static func prefixOpcode19(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit0 = cpu.registerBC.lo.bit(0)
//            let shiftedValue = (cpu.registerBC.lo >> 1) | (carry << 7)
//            cpu.registerBC.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RR r
//        static func prefixOpcode1A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit0 = cpu.registerDE.hi.bit(0)
//            let shiftedValue = (cpu.registerDE.hi >> 1) | (carry << 7)
//            cpu.registerDE.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RR r
//        static func prefixOpcode1B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit0 = cpu.registerDE.lo.bit(0)
//            let shiftedValue = (cpu.registerDE.lo >> 1) | (carry << 7)
//            cpu.registerDE.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RR r
//        static func prefixOpcode1C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit0 = cpu.registerHL.hi.bit(0)
//            let shiftedValue = (cpu.registerHL.hi >> 1) | (carry << 7)
//            cpu.registerHL.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RR r
//        static func prefixOpcode1D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit0 = cpu.registerHL.lo.bit(0)
//            let shiftedValue = (cpu.registerHL.lo >> 1) | (carry << 7)
//            cpu.registerHL.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RR HL
//        static func prefixOpcode1E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let carry = cpu.carryFlag.toUInt8()
//            let bit0 = value.bit(0)
//            let shiftedValue = (value >> 1) | (carry << 7)
//            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RR r
//        static func prefixOpcode1F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let carry = cpu.carryFlag.toUInt8()
//            let bit0 = cpu.registerAF.hi.bit(0)
//            let shiftedValue = (cpu.registerAF.hi >> 1) | (carry << 7)
//            cpu.registerAF.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        
//        // MARK: - 0x2
//        /// SLA r
//        static func prefixOpcode20(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerBC.hi.bit(7)
//            let shiftedValue = (cpu.registerBC.hi << 1)
//            cpu.registerBC.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SLA r
//        static func prefixOpcode21(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerBC.lo.bit(7)
//            let shiftedValue = (cpu.registerBC.lo << 1)
//            cpu.registerBC.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SLA r
//        static func prefixOpcode22(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerDE.hi.bit(7)
//            let shiftedValue = (cpu.registerDE.hi << 1)
//            cpu.registerDE.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SLA r
//        static func prefixOpcode23(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerDE.lo.bit(7)
//            let shiftedValue = (cpu.registerDE.lo << 1)
//            cpu.registerDE.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SLA r
//        static func prefixOpcode24(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerHL.hi.bit(7)
//            let shiftedValue = (cpu.registerHL.hi << 1)
//            cpu.registerHL.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SLA r
//        static func prefixOpcode25(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerHL.lo.bit(7)
//            let shiftedValue = (cpu.registerHL.lo << 1)
//            cpu.registerHL.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SLA HL
//        static func prefixOpcode26(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let bit7 = value.bit(7)
//            let shiftedValue = (value << 1)
//            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SLA r
//        static func prefixOpcode27(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerAF.hi.bit(7)
//            let shiftedValue = (cpu.registerAF.hi << 1)
//            cpu.registerAF.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit7)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRA r
//        static func prefixOpcode28(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerBC.hi.bit(7)
//            let bit0 = cpu.registerBC.hi.bit(0)
//            let shiftedValue = (cpu.registerBC.hi >> 1) | (bit7.toUInt8() << 7)
//            cpu.registerBC.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRA r
//        static func prefixOpcode29(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerBC.lo.bit(7)
//            let bit0 = cpu.registerBC.lo.bit(0)
//            let shiftedValue = (cpu.registerBC.lo >> 1) | (bit7.toUInt8() << 7)
//            cpu.registerBC.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRA r
//        static func prefixOpcode2A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerDE.hi.bit(7)
//            let bit0 = cpu.registerDE.hi.bit(0)
//            let shiftedValue = (cpu.registerDE.hi >> 1) | (bit7.toUInt8() << 7)
//            cpu.registerDE.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRA r
//        static func prefixOpcode2B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerDE.lo.bit(7)
//            let bit0 = cpu.registerDE.lo.bit(0)
//            let shiftedValue = (cpu.registerDE.lo >> 1) | (bit7.toUInt8() << 7)
//            cpu.registerDE.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRA r
//        static func prefixOpcode2C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerHL.hi.bit(7)
//            let bit0 = cpu.registerHL.hi.bit(0)
//            let shiftedValue = (cpu.registerHL.hi >> 1) | (bit7.toUInt8() << 7)
//            cpu.registerHL.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRA r
//        static func prefixOpcode2D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerHL.lo.bit(7)
//            let bit0 = cpu.registerHL.lo.bit(0)
//            let shiftedValue = (cpu.registerHL.lo >> 1) | (bit7.toUInt8() << 7)
//            cpu.registerHL.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRA HL
//        static func prefixOpcode2E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let bit7 = value.bit(7)
//            let bit0 = value.bit(0)
//            let shiftedValue = (value >> 1) | (bit7.toUInt8() << 7)
//            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRA r
//        static func prefixOpcode2F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit7 = cpu.registerAF.hi.bit(7)
//            let bit0 = cpu.registerAF.hi.bit(0)
//            let shiftedValue = (cpu.registerAF.hi >> 1) | (bit7.toUInt8() << 7)
//            cpu.registerAF.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        
//        // MARK: - 0x3
//        /// SWAP r
//        static func prefixOpcode30(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let highNibbles = (cpu.registerBC.hi & 0xF0) >> 4
//            let lowNibbles = (cpu.registerBC.hi & 0x0F) << 4
//            let swappedValue = lowNibbles | highNibbles
//            cpu.registerBC.hi = swappedValue
//            let flag = ALU.Flag(
//                zero: .some(swappedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(false)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SWAP r
//        static func prefixOpcode31(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let highNibbles = (cpu.registerBC.lo & 0xF0) >> 4
//            let lowNibbles = (cpu.registerBC.lo & 0x0F) << 4
//            let swappedValue = lowNibbles | highNibbles
//            cpu.registerBC.lo = swappedValue
//            let flag = ALU.Flag(
//                zero: .some(swappedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(false)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SWAP r
//        static func prefixOpcode32(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let highNibbles = (cpu.registerDE.hi & 0xF0) >> 4
//            let lowNibbles = (cpu.registerDE.hi & 0x0F) << 4
//            let swappedValue = lowNibbles | highNibbles
//            cpu.registerDE.hi = swappedValue
//            let flag = ALU.Flag(
//                zero: .some(swappedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(false)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SWAP r
//        static func prefixOpcode33(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let highNibbles = (cpu.registerDE.lo & 0xF0) >> 4
//            let lowNibbles = (cpu.registerDE.lo & 0x0F) << 4
//            let swappedValue = lowNibbles | highNibbles
//            cpu.registerDE.lo = swappedValue
//            let flag = ALU.Flag(
//                zero: .some(swappedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(false)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SWAP r
//        static func prefixOpcode34(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let highNibbles = (cpu.registerHL.hi & 0xF0) >> 4
//            let lowNibbles = (cpu.registerHL.hi & 0x0F) << 4
//            let swappedValue = lowNibbles | highNibbles
//            cpu.registerHL.hi = swappedValue
//            let flag = ALU.Flag(
//                zero: .some(swappedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(false)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SWAP r
//        static func prefixOpcode35(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let highNibbles = (cpu.registerHL.lo & 0xF0) >> 4
//            let lowNibbles = (cpu.registerHL.lo & 0x0F) << 4
//            let swappedValue = lowNibbles | highNibbles
//            cpu.registerHL.lo = swappedValue
//            let flag = ALU.Flag(
//                zero: .some(swappedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(false)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SWAP HL
//        static func prefixOpcode36(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let highNibbles = (value & 0xF0) >> 4
//            let lowNibbles = (value & 0x0F) << 4
//            let swappedValue = lowNibbles | highNibbles
//            writeMemory(&cpu, swappedValue, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(swappedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(false)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SWAP r
//        static func prefixOpcode37(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let highNibbles = (cpu.registerAF.hi & 0xF0) >> 4
//            let lowNibbles = (cpu.registerAF.hi & 0x0F) << 4
//            let swappedValue = lowNibbles | highNibbles
//            cpu.registerAF.hi = swappedValue
//            let flag = ALU.Flag(
//                zero: .some(swappedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(false)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRL r
//        static func prefixOpcode38(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerBC.hi.bit(0)
//            let shiftedValue = cpu.registerBC.hi >> 1
//            cpu.registerBC.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRL r
//        static func prefixOpcode39(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerBC.lo.bit(0)
//            let shiftedValue = cpu.registerBC.lo >> 1
//            cpu.registerBC.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRL r
//        static func prefixOpcode3A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerDE.hi.bit(0)
//            let shiftedValue = cpu.registerDE.hi >> 1
//            cpu.registerDE.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRL r
//        static func prefixOpcode3B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerDE.lo.bit(0)
//            let shiftedValue = cpu.registerDE.lo >> 1
//            cpu.registerDE.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRL r
//        static func prefixOpcode3C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerHL.hi.bit(0)
//            let shiftedValue = cpu.registerHL.hi >> 1
//            cpu.registerHL.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRL r
//        static func prefixOpcode3D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerHL.lo.bit(0)
//            let shiftedValue = cpu.registerHL.lo >> 1
//            cpu.registerHL.lo = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRL HL
//        static func prefixOpcode3E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let bit0 = value.bit(0)
//            let shiftedValue = value >> 1
//            writeMemory(&cpu, shiftedValue, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// SRL r
//        static func prefixOpcode3F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let bit0 = cpu.registerAF.hi.bit(0)
//            let shiftedValue = cpu.registerAF.hi >> 1
//            cpu.registerAF.hi = shiftedValue
//            let flag = ALU.Flag(
//                zero: .some(shiftedValue == 0),
//                subtract: .some(false),
//                halfCarry: .some(false),
//                carry: .some(bit0)
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode40(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.hi.checkBit(at: 0, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode41(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.lo.checkBit(at: 0, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode42(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.hi.checkBit(at: 0, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode43(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.lo.checkBit(at: 0, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode44(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.hi.checkBit(at: 0, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode45(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.lo.checkBit(at: 0, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, (HL)
//        static func prefixOpcode46(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(value.checkBit(at: 0, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode47(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerAF.hi.checkBit(at: 0, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode48(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.hi.checkBit(at: 1, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode49(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.lo.checkBit(at: 1, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode4A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.hi.checkBit(at: 1, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode4B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.lo.checkBit(at: 1, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode4C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.hi.checkBit(at: 1, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode4D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.lo.checkBit(at: 1, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, (HL)
//        static func prefixOpcode4E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(value.checkBit(at: 1, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode4F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerAF.hi.checkBit(at: 1, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode50(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.hi.checkBit(at: 2, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode51(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.lo.checkBit(at: 2, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode52(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.hi.checkBit(at: 2, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode53(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.lo.checkBit(at: 2, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode54(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.hi.checkBit(at: 2, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode55(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.lo.checkBit(at: 2, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, (HL)
//        static func prefixOpcode56(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(value.checkBit(at: 2, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode57(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerAF.hi.checkBit(at: 2, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode58(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.hi.checkBit(at: 3, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode59(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.lo.checkBit(at: 3, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode5A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.hi.checkBit(at: 3, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode5B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.lo.checkBit(at: 3, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode5C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.hi.checkBit(at: 3, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode5D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.lo.checkBit(at: 3, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, (HL)
//        static func prefixOpcode5E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(value.checkBit(at: 3, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode5F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerAF.hi.checkBit(at: 3, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode60(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.hi.checkBit(at: 4, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode61(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.lo.checkBit(at: 4, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode62(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.hi.checkBit(at: 4, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode63(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.lo.checkBit(at: 4, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode64(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.hi.checkBit(at: 4, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode65(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.lo.checkBit(at: 4, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, (HL)
//        static func prefixOpcode66(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(value.checkBit(at: 4, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode67(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerAF.hi.checkBit(at: 4, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode68(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.hi.checkBit(at: 5, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode69(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.lo.checkBit(at: 5, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode6A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.hi.checkBit(at: 5, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode6B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.lo.checkBit(at: 5, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode6C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.hi.checkBit(at: 5, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode6D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.lo.checkBit(at: 5, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, (HL)
//        static func prefixOpcode6E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(value.checkBit(at: 5, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode6F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerAF.hi.checkBit(at: 5, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode70(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.hi.checkBit(at: 6, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode71(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.lo.checkBit(at: 6, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode72(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.hi.checkBit(at: 6, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode73(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.lo.checkBit(at: 6, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode74(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.hi.checkBit(at: 6, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode75(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.lo.checkBit(at: 6, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, (HL)
//        static func prefixOpcode76(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(value.checkBit(at: 6, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode77(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerAF.hi.checkBit(at: 6, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode78(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.hi.checkBit(at: 7, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode79(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerBC.lo.checkBit(at: 7, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode7A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.hi.checkBit(at: 7, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode7B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerDE.lo.checkBit(at: 7, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode7C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.hi.checkBit(at: 7, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode7D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerHL.lo.checkBit(at: 7, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, (HL)
//        static func prefixOpcode7E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all)
//            let flag = ALU.Flag(
//                zero: .some(value.checkBit(at: 7, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// BIT b, r
//        static func prefixOpcode7F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let flag = ALU.Flag(
//                zero: .some(cpu.registerAF.hi.checkBit(at: 7, equalTo: 0)),
//                subtract: .some(false),
//                halfCarry: .some(true),
//                carry: .noneAffected
//            )
//            cpu.updateFlag(flag)
//        }
//        /// RES b, r
//        static func prefixOpcode80(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcode81(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcode82(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcode83(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcode84(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcode85(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 0)
//        }
//        /// RES b, HL
//        static func prefixOpcode86(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 0)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcode87(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcode88(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcode89(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcode8A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcode8B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcode8C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcode8D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 1)
//        }
//        /// RES b, HL
//        static func prefixOpcode8E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 1)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcode8F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcode90(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcode91(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcode92(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcode93(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcode94(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcode95(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 2)
//        }
//        /// RES b, HL
//        static func prefixOpcode96(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 2)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcode97(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcode98(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcode99(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcode9A(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcode9B(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcode9C(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcode9D(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 3)
//        }
//        /// RES b, HL
//        static func prefixOpcode9E(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 3)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcode9F(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcodeA0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeA1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeA2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeA3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeA4(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeA5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 4)
//        }
//        /// RES b, HL
//        static func prefixOpcodeA6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 4)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeA7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeA8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeA9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeAA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeAB(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeAC(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeAD(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 5)
//        }
//        /// RES b, HL
//        static func prefixOpcodeAE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 5)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeAF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeB0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeB1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeB2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeB3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeB4(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeB5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 6)
//        }
//        /// RES b, HL
//        static func prefixOpcodeB6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 6)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeB7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeB8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitUnset(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeB9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitUnset(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeBA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitUnset(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeBB(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitUnset(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeBC(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitUnset(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeBD(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitUnset(at: 7)
//        }
//        /// RES b, HL
//        static func prefixOpcodeBE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitUnset(at: 7)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeBF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitUnset(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeC0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcodeC1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcodeC2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcodeC3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcodeC4(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcodeC5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 0)
//        }
//        /// RES b, HL
//        static func prefixOpcodeC6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 0)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeC7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 0)
//        }
//        /// RES b, r
//        static func prefixOpcodeC8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcodeC9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcodeCA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcodeCB(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcodeCC(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcodeCD(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 1)
//        }
//        /// RES b, HL
//        static func prefixOpcodeCE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 1)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeCF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 1)
//        }
//        /// RES b, r
//        static func prefixOpcodeD0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcodeD1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcodeD2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcodeD3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcodeD4(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcodeD5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 2)
//        }
//        /// RES b, HL
//        static func prefixOpcodeD6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 2)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeD7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 2)
//        }
//        /// RES b, r
//        static func prefixOpcodeD8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcodeD9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcodeDA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcodeDB(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcodeDC(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcodeDD(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 3)
//        }
//        /// RES b, HL
//        static func prefixOpcodeDE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 3)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeDF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 3)
//        }
//        /// RES b, r
//        static func prefixOpcodeE0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeE1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeE2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeE3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeE4(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeE5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 4)
//        }
//        /// RES b, HL
//        static func prefixOpcodeE6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 4)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeE7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 4)
//        }
//        /// RES b, r
//        static func prefixOpcodeE8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeE9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeEA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeEB(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeEC(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeED(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 5)
//        }
//        /// RES b, HL
//        static func prefixOpcodeEE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 5)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeEF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 5)
//        }
//        /// RES b, r
//        static func prefixOpcodeF0(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeF1(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeF2(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeF3(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeF4(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeF5(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 6)
//        }
//        /// RES b, HL
//        static func prefixOpcodeF6(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 6)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeF7(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 6)
//        }
//        /// RES b, r
//        static func prefixOpcodeF8(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.hi = cpu.registerBC.hi.withBitSet(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeF9(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerBC.lo = cpu.registerBC.lo.withBitSet(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeFA(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.hi = cpu.registerDE.hi.withBitSet(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeFB(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerDE.lo = cpu.registerDE.lo.withBitSet(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeFC(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.hi = cpu.registerHL.hi.withBitSet(at: 7)
//        }
//        /// RES b, r
//        static func prefixOpcodeFD(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerHL.lo = cpu.registerHL.lo.withBitSet(at: 7)
//        }
//        /// RES b, HL
//        static func prefixOpcodeFE(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            let value = readMemory(cpu, cpu.registerHL.all).withBitSet(at: 7)
//            writeMemory(&cpu, value, cpu.registerHL.all)
//        }
//        /// RES b, r
//        static func prefixOpcodeFF(cpu: inout CPU, readMemory: MemoryReadHandlerV2, writeMemory: MemoryWriteHandlerV2) {
//            cpu.registerAF.hi = cpu.registerAF.hi.withBitSet(at: 7)
//        }
//    ]

//enum InstructionV3 {
//    static func prefixOpcode(_ context: inout some CPUContext) {
//        context.cpu.interruptMasterEnabled = true
////        context.read(/*<#T##address: UInt16##UInt16#>*/)
//    }
//}
