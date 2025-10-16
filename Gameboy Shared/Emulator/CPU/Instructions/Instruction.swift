//
//  InstructionV5.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 20/9/2568 BE.
//

import Foundation

enum Instruction {
    static func ld_rr(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let to = (opcode & 0b0011_1000) >> 3
        let from = opcode & 0b0000_0111
        gb.cpu.setRegister(to, value: gb.cpu.getRegister(from))
    }
    
    static func ld_rn(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let to = (opcode & 0b0011_1000) >> 3
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        gb.cpu.setRegister(to, value: value)
    }
    
    static func ld_r_hlmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let to = (opcode & 0b0011_1000) >> 3
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        gb.cpu.setRegister(to, value: value)
    }
    
    static func ld_hlmem_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 8)
        let value = gb.cpu.getRegister(opcode & 0b0000_0111)
        gb.write(value, to: gb.cpu.registerHL.all)
    }
    
    static func ld_hlmem_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        gb.write(value, to: gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
    }
    
    static func ld_A_BCmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerBC.all)
        gb.advance(cycles: 4)
        gb.cpu.registerAF.hi = value
    }
    
    static func ld_A_DEmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerDE.all)
        gb.advance(cycles: 4)
        gb.cpu.registerAF.hi = value
    }
    
    static func ld_BCmem_A(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.write(gb.cpu.registerAF.hi, to: gb.cpu.registerBC.all)
        gb.advance(cycles: 4)
    }
    
    static func ld_DEmem_A(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.write(gb.cpu.registerAF.hi, to: gb.cpu.registerDE.all)
        gb.advance(cycles: 4)
    }
    
    static func ld_A_a16mem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let lsb = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let msb = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let address = UInt16(msb) << 8 | UInt16(lsb)
        let value = gb.read(address)
        gb.advance(cycles: 4)
        gb.cpu.registerAF.hi = value
    }
    
    static func ld_a16mem_A(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let lsb = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let msb = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        gb.write(gb.cpu.registerAF.hi, to: UInt16(msb) << 8 | UInt16(lsb))
        gb.advance(cycles: 4)
    }
    
    static func ld_A_Cmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let lsb = gb.cpu.registerBC.lo
        let address: UInt16 = 0xFF00 | UInt16(lsb)
        let value = gb.read(address)
        gb.advance(cycles: 4)
        gb.cpu.registerAF.hi = value
    }
    
    static func ld_Cmem_A(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.write(gb.cpu.registerAF.hi, to: 0xFF00 | UInt16(gb.cpu.registerBC.lo))
        gb.advance(cycles: 4)
    }
    
    static func ld_A_a8mem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let lsb = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let value = gb.read(0xFF00 | UInt16(lsb))
        gb.advance(cycles: 4)
        gb.cpu.registerAF.hi = value
    }
    
    static func ld_a8mem_A(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let lsb = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        gb.write(gb.cpu.registerAF.hi, to: 0xFF00 | UInt16(lsb))
        gb.advance(cycles: 4)
    }
    
    static func ld_A_HLdec(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.cpu.registerHL.all &-= 1
        gb.advance(cycles: 4)
        gb.cpu.registerAF.hi = value
    }
    
    static func ld_HLdec_A(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.write(gb.cpu.registerAF.hi, to: gb.cpu.registerHL.all)
        gb.cpu.registerHL.all &-= 1
        gb.advance(cycles: 4)
    }
    
    static func ld_A_HLinc(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.cpu.registerHL.all &+= 1
        gb.advance(cycles: 4)
        gb.cpu.registerAF.hi = value
    }
    
    static func ld_HLinc_A(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.write(gb.cpu.registerAF.hi, to: gb.cpu.registerHL.all)
        gb.cpu.registerHL.all &+= 1
        gb.advance(cycles: 4)
    }
    
    /// LD 16 bit
    static func ld_rr_a16(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let lsb = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let msb = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        gb.cpu.setPairedRegisterWithSP((opcode >> 4) & 0x3, value: UInt16(msb) << 8 | UInt16(lsb))
    }
    
    static func ld_a16mem_sp(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let lsb = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let msb = gb.read(gb.cpu.programCounter)
        var address = UInt16(msb) << 8 | UInt16(lsb)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        gb.write(UInt8(gb.cpu.stackPointer & 0xFF), to: address)
        address += 1
        gb.advance(cycles: 4)
        gb.write(UInt8((gb.cpu.stackPointer >> 8) & 0xFF), to: address)
        gb.advance(cycles: 4)
    }
    
    static func ld_sp_hl(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.cpu.stackPointer = gb.cpu.registerHL.all
        gb.advance(cycles: 4)
    }
    
    static func push_rr(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.cpu.stackPointer -= 1
        gb.advance(cycles: 4)
        let registerID = (opcode >> 4) & 0x03
        let value = gb.cpu.getPairedRegisterWithAF(registerID)
        gb.write(UInt8(value >> 8) & 0xFF, to: gb.cpu.stackPointer)
        gb.cpu.stackPointer -= 1
        gb.advance(cycles: 4)
        gb.write(UInt8(value & 0xFF), to: gb.cpu.stackPointer)
        gb.advance(cycles: 4)
    }
    
    static func pop_rr(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let lsb = gb.read(gb.cpu.stackPointer)
        gb.cpu.stackPointer += 1
        gb.advance(cycles: 4)
        let msb = gb.read(gb.cpu.stackPointer)
        gb.cpu.stackPointer += 1
        gb.advance(cycles: 4)
        let value: UInt16 = (UInt16(msb) << 8) | UInt16(lsb)
        let registerID = (opcode >> 4) & 0x03
        gb.cpu.setPairedRegisterWithAF(registerID, value: value)
    }
    
    static func ld_hl_spe(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let signedValue = Int8(bitPattern: value)
        let halfCarry = ALU.checkCarry(
            gb.cpu.stackPointer,
            UInt16(bitPattern: Int16(signedValue)),
            carryBit: 3)
        let carry = ALU.checkCarry(
            gb.cpu.stackPointer,
            UInt16(bitPattern: Int16(signedValue)),
            carryBit: 7)
        gb.cpu.updateFlag(
            ALU.Flag(
                zero: .some(false),
                subtract: .some(false),
                halfCarry: .some(halfCarry),
                carry: .some(carry)
            )
        )
        gb.advance(cycles: 4)
        gb.cpu.registerHL.all = gb.cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
        
    }
    
    /// 8 bit arithmetic
    static func add_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let result = ALU.add(
            gb.cpu.registerAF.hi,
            gb.cpu.getRegister(opcode & 0b0000_0111))
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func add_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let result = ALU.add(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func add_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let result = ALU.add(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func adc_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let result = ALU.add(
            gb.cpu.registerAF.hi,
            gb.cpu.getRegister(opcode & 0b0000_0111),
            carry: gb.cpu.carryFlag)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func adc_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let result = ALU.add(gb.cpu.registerAF.hi, value, carry: gb.cpu.carryFlag)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func adc_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let result = ALU.add(gb.cpu.registerAF.hi, value, carry: gb.cpu.carryFlag)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func sub_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let result = ALU.sub(
            gb.cpu.registerAF.hi,
            gb.cpu.getRegister(opcode & 0b0000_0111))
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func sub_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let result = ALU.sub(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func sub_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let result = ALU.sub(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func sbc_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let result = ALU.sub(
            gb.cpu.registerAF.hi,
            gb.cpu.getRegister(opcode & 0b0000_0111),
            carry: gb.cpu.carryFlag)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func sbc_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let result = ALU.sub(
            gb.cpu.registerAF.hi,
            value,
            carry: gb.cpu.carryFlag)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func sbc_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let result = ALU.sub(
            gb.cpu.registerAF.hi,
            value,
            carry: gb.cpu.carryFlag)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func cp_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let result = ALU.sub(gb.cpu.registerAF.hi, gb.cpu.getRegister(opcode & 0x7))
        gb.cpu.updateFlag(result.flag)
    }
    
    static func cp_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        let result = ALU.sub(gb.cpu.registerAF.hi, value)
        gb.cpu.updateFlag(result.flag)
    }
    
    static func cp_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let result = ALU.sub(gb.cpu.registerAF.hi, value)
        gb.cpu.updateFlag(result.flag)
    }
    
    static func inc_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = (opcode >> 3) & 0b0000_0111
        let result = ALU.increment(gb.cpu.getRegister(registerID))
        gb.cpu.setRegister(registerID, value: result.value)
        gb.cpu.updateFlag(result.flag)
    }
    
    static func inc_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let result = ALU.increment(value)
        gb.write(result.value, to: gb.cpu.registerHL.all)
        gb.cpu.updateFlag(result.flag)
        gb.advance(cycles: 4)
    }
    
    static func dec_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = (opcode >> 3) & 0b0000_0111
        let result = ALU.decrement(gb.cpu.getRegister(registerID))
        gb.cpu.setRegister(registerID, value: result.value)
        gb.cpu.updateFlag(result.flag)
    }
    
    static func dec_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let result = ALU.decrement(value)
        gb.write(result.value, to: gb.cpu.registerHL.all)
        gb.cpu.updateFlag(result.flag)
        gb.advance(cycles: 4)
    }
    
    static func and_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let result = ALU.and(
            gb.cpu.registerAF.hi,
            gb.cpu.getRegister(opcode & 0b0000_0111))
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func and_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let result = ALU.and(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func and_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let result = ALU.and(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func or_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let result = ALU.or(
            gb.cpu.registerAF.hi,
            gb.cpu.getRegister(opcode & 0b0000_0111))
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func or_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let result = ALU.or(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func or_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let result = ALU.or(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func xor_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let result = ALU.xor(
            gb.cpu.registerAF.hi,
            gb.cpu.getRegister(opcode & 0b0000_0111))
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func xor_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let result = ALU.xor(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func xor_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let result = ALU.xor(gb.cpu.registerAF.hi, value)
        gb.cpu.registerAF.hi = result.value
        gb.cpu.updateFlag(result.flag)
    }
    
    static func ccf(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let flag = ALU.Flag(
            zero: .noneAffected,
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(!gb.cpu.carryFlag)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func scf(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let flag = ALU.Flag(
            zero: .noneAffected,
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(true)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func daa(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
    }
    
    static func cpl(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.cpu.registerAF.hi = ~gb.cpu.registerAF.hi
        let flag = ALU.Flag(
            zero: .noneAffected,
            subtract: .some(true),
            halfCarry: .some(true),
            carry: .noneAffected
        )
        gb.cpu.updateFlag(flag)
    }
    
    /// 16 bit arithmetic
    static func inc_rr(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = (opcode >> 4) & 0x3
        gb.cpu.setPairedRegisterWithSP(
            registerID,
            value: gb.cpu.getPairedRegisterWithSP(registerID) &+ 1)
        gb.advance(cycles: 4)
    }
    
    static func dec_rr(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = (opcode >> 4) & 0x3
        gb.cpu.setPairedRegisterWithSP(
            registerID,
            value: gb.cpu.getPairedRegisterWithSP(registerID) &- 1)
        gb.advance(cycles: 4)
    }
    
    static func add_HL_rr(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let register = gb.cpu.getPairedRegisterWithSP((opcode >> 4) & 0x3)
        let result = ALU.add16(
            gb.cpu.registerHL.all,
            register,
            carryBit: 11)
        gb.cpu.updateFlag(
            ALU.Flag(
                zero: .noneAffected,
                subtract: result.flag.subtract,
                halfCarry: result.flag.halfCarry,
                carry: result.flag.carry
            )
        )
        gb.cpu.registerHL.all = result.value
        gb.advance(cycles: 4)
    }
    
    static func add_sp_e(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let signedValue = Int8(bitPattern: value)
        let halfCarry = ALU.checkCarry(
            gb.cpu.stackPointer,
            UInt16(bitPattern: Int16(signedValue)),
            carryBit: 3)
        let carry = ALU.checkCarry(
            gb.cpu.stackPointer,
            UInt16(bitPattern: Int16(signedValue)),
            carryBit: 7)
        let flag = ALU.Flag(
            zero: .some(false),
            subtract: .some(false),
            halfCarry: .some(halfCarry),
            carry: .some(carry)
        )
        gb.cpu.updateFlag(flag)
        gb.advance(cycles: 8)
        gb.cpu.stackPointer = gb.cpu.stackPointer &+ UInt16(bitPattern: Int16(signedValue))
    }
    
    /// rotate, shift
    static func rlca(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let bit7 = gb.cpu.registerAF.hi.bit(7)
        let shiftedValue = (gb.cpu.registerAF.hi << 1) | bit7.toUInt8()
        gb.cpu.registerAF.hi = shiftedValue
        let flag = ALU.Flag(
            zero: .some(false),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit7)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func rrca(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let bit0 = gb.cpu.registerAF.hi.bit(0)
        let shiftedValue = (bit0.toUInt8() << 7) | (gb.cpu.registerAF.hi >> 1)
        gb.cpu.registerAF.hi = shiftedValue
        let flag = ALU.Flag(
            zero: .some(false),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func rla(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let carry = gb.cpu.carryFlag.toUInt8()
        let bit7 = gb.cpu.registerAF.hi.bit(7)
        let shiftedValue = (gb.cpu.registerAF.hi << 1) | carry
        gb.cpu.registerAF.hi = shiftedValue
        let flag = ALU.Flag(
            zero: .some(false),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit7)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func rra(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let carry = gb.cpu.carryFlag.toUInt8()
        let bit0 = gb.cpu.registerAF.hi.bit(0)
        let shiftedValue = (gb.cpu.registerAF.hi >> 1) | (carry << 7)
        gb.cpu.registerAF.hi = shiftedValue
        let flag = ALU.Flag(
            zero: .some(false),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func rlc_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let bit7 = register.bit(7)
        let shiftedValue = (register << 1) | bit7.toUInt8()
        gb.cpu.setRegister(registerID, value: shiftedValue)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit7)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func rlc_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let bit7 = value.bit(7)
        let shiftedValue = (value << 1) | bit7.toUInt8()
        gb.write(shiftedValue, to: gb.cpu.registerHL.all)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit7)
        )
        gb.cpu.updateFlag(flag)
        gb.advance(cycles: 4)
    }
    
    static func rrc_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let bit0 = register.bit(0)
        let shiftedValue = (register >> 1) | (bit0.toUInt8() << 7)
        gb.cpu.setRegister(registerID, value: shiftedValue)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func rrc_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let bit0 = value.bit(0)
        let shiftedValue = (value >> 1) | (bit0.toUInt8() << 7)
        gb.write(shiftedValue, to: gb.cpu.registerHL.all)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
        gb.advance(cycles: 4)
    }
    
    static func rl_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let carry = gb.cpu.carryFlag.toUInt8()
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let bit7 = register.bit(7)
        let shiftedValue = (register << 1) | carry
        gb.cpu.setRegister(registerID, value: shiftedValue)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit7)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func rl_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let carry = gb.cpu.carryFlag.toUInt8()
        let bit7 = value.bit(7)
        let shiftedValue = (value << 1) | carry
        gb.write(shiftedValue, to: gb.cpu.registerHL.all)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit7)
        )
        gb.cpu.updateFlag(flag)
        gb.advance(cycles: 4)
    }
    
    static func rr_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let carry = gb.cpu.carryFlag.toUInt8()
        let bit0 = register.bit(0)
        let shiftedValue = (register >> 1) | (carry << 7)
        gb.cpu.setRegister(registerID, value: shiftedValue)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func rr_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let carry = gb.cpu.carryFlag.toUInt8()
        let bit0 = value.bit(0)
        let shiftedValue = (value >> 1) | (carry << 7)
        gb.write(shiftedValue, to: gb.cpu.registerHL.all)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
        gb.advance(cycles: 4)
    }
    
    static func sla_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let bit7 = register.bit(7)
        let shiftedValue = (register << 1)
        gb.cpu.setRegister(registerID, value: shiftedValue)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit7)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func sla_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let bit7 = value.bit(7)
        let shiftedValue = (value << 1)
        gb.write(shiftedValue, to: gb.cpu.registerHL.all)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit7)
        )
        gb.cpu.updateFlag(flag)
        gb.advance(cycles: 4)
    }
    
    static func sra_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let bit7 = register.bit(7)
        let bit0 = register.bit(0)
        let shiftedValue = (register >> 1) | (bit7.toUInt8() << 7)
        gb.cpu.setRegister(registerID, value: shiftedValue)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func sra_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let bit7 = value.bit(7)
        let bit0 = value.bit(0)
        let shiftedValue = (value >> 1) | (bit7.toUInt8() << 7)
        gb.write(shiftedValue, to: gb.cpu.registerHL.all)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
        gb.advance(cycles: 4)
    }
    
    static func swap_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let highNibbles = (register & 0xF0) >> 4
        let lowNibbles = (register & 0x0F) << 4
        let swappedValue = lowNibbles | highNibbles
        gb.cpu.setRegister(registerID, value: swappedValue)
        let flag = ALU.Flag(
            zero: .some(swappedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(false)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func swap_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let highNibbles = (value & 0xF0) >> 4
        let lowNibbles = (value & 0x0F) << 4
        let swappedValue = lowNibbles | highNibbles
        gb.write(swappedValue, to: gb.cpu.registerHL.all)
        let flag = ALU.Flag(
            zero: .some(swappedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(false)
        )
        gb.cpu.updateFlag(flag)
        gb.advance(cycles: 4)
    }
    
    static func srl_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let bit0 = register.bit(0)
        let shiftedValue = register >> 1
        gb.cpu.setRegister(registerID, value: shiftedValue)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func srl_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let bit0 = value.bit(0)
        let shiftedValue = value >> 1
        gb.write(shiftedValue, to: gb.cpu.registerHL.all)
        let flag = ALU.Flag(
            zero: .some(shiftedValue == 0),
            subtract: .some(false),
            halfCarry: .some(false),
            carry: .some(bit0)
        )
        gb.cpu.updateFlag(flag)
        gb.advance(cycles: 4)
    }
    
    static func bit_n_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let register = gb.cpu.getRegister(opcode & 0x7)
        let bitIndex = (opcode >> 3) & 0x7
        let flag = ALU.Flag(
            zero: .some(
                register.checkBit(at: bitIndex, equalTo: 0)),
            subtract: .some(false),
            halfCarry: .some(true),
            carry: .noneAffected
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func bit_n_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let bitIndex = (opcode >> 3) & 0x7
        let value = gb.read(gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
        let flag = ALU.Flag(
            zero: .some(value.checkBit(at: bitIndex, equalTo: 0)),
            subtract: .some(false),
            halfCarry: .some(true),
            carry: .noneAffected
        )
        gb.cpu.updateFlag(flag)
    }
    
    static func res_n_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let bitIndex = (opcode >> 3) & 0x7
        gb.cpu.setRegister(
            registerID,
            value: register.withBitUnset(at: bitIndex))
    }
    
    static func res_n_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let bitIndex = (opcode >> 3) & 0x7
        let value = gb.read(gb.cpu.registerHL.all).withBitUnset(at: bitIndex)
        gb.advance(cycles: 4)
        gb.write(value, to: gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
    }
    
    static func set_n_r(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let registerID = opcode & 0x7
        let register = gb.cpu.getRegister(registerID)
        let bitIndex = (opcode >> 3) & 0x7
        gb.cpu.setRegister(
            registerID,
            value: register.withBitSet(at: bitIndex))
    }
    
    static func set_n_HLmem(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let bitIndex = (opcode >> 3) & 0x7
        let value = gb.read(gb.cpu.registerHL.all).withBitSet(at: bitIndex)
        gb.advance(cycles: 4)
        gb.write(value, to: gb.cpu.registerHL.all)
        gb.advance(cycles: 4)
    }
    
    /// Control flow
    static func jp_a16(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let leastSignificantByte = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let mostSignificantByte = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        gb.cpu.programCounter = address
        gb.advance(cycles: 4)
    }
    
    static func jp_HL(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.cpu.programCounter = gb.cpu.registerHL.all
    }
    
    static func jp_cc_a16(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let leastSignificantByte = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let mostSignificantByte = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        let conditionMet = switch ((opcode >> 3) & 0x3) {
        case 0: !gb.cpu.zeroFlag
        case 1: gb.cpu.zeroFlag
        case 2: !gb.cpu.carryFlag
        case 3: gb.cpu.carryFlag
        default: fatalError()
        }
        if conditionMet {
            gb.advance(cycles: 4)
            let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            gb.cpu.programCounter = address
            gb.advance(cycles: 4)
        } else {
            gb.advance(cycles: 4)
        }
    }
    
    static func jr_e(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let signedValue = Int16(Int8(bitPattern: value))
        let programCounter = Int16(bitPattern: gb.cpu.programCounter)
        let address = programCounter + signedValue
        gb.advance(cycles: 4)
        gb.cpu.programCounter = UInt16(bitPattern: address)
    }
    
    static func jr_cc_e(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let conditionMet = switch ((opcode >> 3) & 0x3) {
        case 0: !gb.cpu.zeroFlag
        case 1: gb.cpu.zeroFlag
        case 2: !gb.cpu.carryFlag
        case 3: gb.cpu.carryFlag
        default: fatalError()
        }
        let value = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        if conditionMet {
            gb.advance(cycles: 4)
            
            let signedValue = Int8(bitPattern: value)
            gb.advance(cycles: 4)
            gb.cpu.programCounter &+= UInt16(bitPattern: Int16(signedValue))
        } else {
            gb.advance(cycles: 4)
        }
    }
    
    static func call_a16(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let leastSignificantByte = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let mostSignificantByte = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        
        gb.cpu.stackPointer -= 1
        gb.advance(cycles: 4)
        gb.write(
            UInt8(gb.cpu.programCounter >> 8),
            to: gb.cpu.stackPointer)
        gb.cpu.stackPointer -= 1
        gb.advance(cycles: 4)
        gb.write(
            UInt8(gb.cpu.programCounter & 0xFF),
            to: gb.cpu.stackPointer)
        
        gb.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        gb.advance(cycles: 4)
    }
    
    static func call_cc_a16(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let leastSignificantByte = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        gb.advance(cycles: 4)
        let mostSignificantByte = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        let conditionMet = switch ((opcode >> 3) & 0x3) {
        case 0: !gb.cpu.zeroFlag
        case 1: gb.cpu.zeroFlag
        case 2: !gb.cpu.carryFlag
        case 3: gb.cpu.carryFlag
        default: fatalError()
        }
        if conditionMet {
            gb.advance(cycles: 4)
            gb.cpu.stackPointer -= 1
            gb.advance(cycles: 4)
            gb.write(
                UInt8(gb.cpu.programCounter >> 8),
                to: gb.cpu.stackPointer)
            gb.cpu.stackPointer -= 1
            gb.advance(cycles: 4)
            gb.write(
                UInt8(gb.cpu.programCounter & 0xFF),
                to: gb.cpu.stackPointer)
            
            let address = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            gb.cpu.programCounter = address
            gb.advance(cycles: 4)
        } else {
            gb.advance(cycles: 4)
        }
    }
    
    static func ret(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let leastSignificantByte = gb.read(gb.cpu.stackPointer)
        gb.cpu.stackPointer += 1
        gb.advance(cycles: 4)
        let mostSignificantByte = gb.read(gb.cpu.stackPointer)
        gb.cpu.stackPointer += 1
        gb.advance(cycles: 4)
        gb.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        gb.advance(cycles: 4)
    }
    
    static func ret_cc(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let conditionMet = switch ((opcode >> 3) & 0x3) {
        case 0: !gb.cpu.zeroFlag
        case 1: gb.cpu.zeroFlag
        case 2: !gb.cpu.carryFlag
        case 3: gb.cpu.carryFlag
        default: fatalError()
        }
        if conditionMet {
            gb.advance(cycles: 4)
            let leastSignificantByte = gb.read(gb.cpu.stackPointer)
            gb.cpu.stackPointer += 1
            gb.advance(cycles: 4)
            let mostSignificantByte = gb.read(gb.cpu.stackPointer)
            gb.cpu.stackPointer += 1
            gb.advance(cycles: 4)
            gb.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
            gb.advance(cycles: 4)
        } else {
            gb.advance(cycles: 4)
        }
    }
    
    static func reti(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let leastSignificantByte = gb.read(gb.cpu.stackPointer)
        gb.cpu.stackPointer += 1
        gb.advance(cycles: 4)
        let mostSignificantByte = gb.read(gb.cpu.stackPointer)
        gb.cpu.stackPointer += 1
        gb.advance(cycles: 4)
        gb.cpu.programCounter = (UInt16(mostSignificantByte) << 8) | UInt16(leastSignificantByte)
        gb.cpu.interruptMasterEnabled = true
        gb.advance(cycles: 4)
    }
    
    static func rst_a8(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.cpu.stackPointer -= 1
        gb.advance(cycles: 4)
        gb.write(
            UInt8(gb.cpu.programCounter >> 8),
            to: gb.cpu.stackPointer)
        gb.cpu.stackPointer -= 1
        gb.advance(cycles: 4)
        gb.write(
            UInt8(gb.cpu.programCounter & 0xFF),
            to: gb.cpu.stackPointer)
        gb.cpu.programCounter = UInt16(opcode) & 0b0011_1000
        gb.advance(cycles: 4)
    }
    
    /// Misc
    static func halt(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.cpu.isHalted = true
    }
    
    static func stop(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
    }
    
    static func di(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.cpu.interruptMasterEnabled = false
    }
    
    static func ei(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        gb.cpu.interruptMasterEnabled = true
    }
    
    static func nop(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
    }
    
    static func prefixInstrs(opcode: UInt8,  gb: inout GB) {
        gb.advance(cycles: 4)
        let nextOpcode: UInt8 = gb.read(gb.cpu.programCounter)
        gb.cpu.programCounter += 1
        
        switch nextOpcode {
        case 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x7:
            Instruction.rlc_r(opcode: nextOpcode, gb: &gb)
        case 0x8, 0x9, 0xA, 0xB, 0xC, 0xD, 0xF:
            Instruction.rrc_r(opcode: nextOpcode, gb: &gb)
        case 0x06:
            Instruction.rlc_HLmem(opcode: nextOpcode, gb: &gb)
        case 0x0E:
            Instruction.rrc_HLmem(opcode: nextOpcode, gb: &gb)
        case 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x17:
            Instruction.rl_r(opcode: nextOpcode, gb: &gb)
        case 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1F:
            Instruction.rr_r(opcode: nextOpcode, gb: &gb)
        case 0x16:
            Instruction.rl_HLmem(opcode: nextOpcode, gb: &gb)
        case 0x1E:
            Instruction.rr_HLmem(opcode: nextOpcode, gb: &gb)
        case 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x27:
            Instruction.sla_r(opcode: nextOpcode, gb: &gb)
        case 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2F:
            Instruction.sra_r(opcode: nextOpcode, gb: &gb)
        case 0x26:
            Instruction.sla_HLmem(opcode: nextOpcode, gb: &gb)
        case 0x2E:
            Instruction.sra_HLmem(opcode: nextOpcode, gb: &gb)
        case 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x37:
            Instruction.swap_r(opcode: nextOpcode, gb: &gb)
        case 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3F:
            Instruction.srl_r(opcode: nextOpcode, gb: &gb)
        case 0x36:
            Instruction.swap_HLmem(opcode: nextOpcode, gb: &gb)
        case 0x3E:
            Instruction.srl_HLmem(opcode: nextOpcode, gb: &gb)
        case 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4F, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5F, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6F, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7F:
            Instruction.bit_n_r(opcode: nextOpcode, gb: &gb)
        case 0x46, 0x56, 0x66, 0x76, 0x4E, 0x5E, 0x6E, 0x7E:
            Instruction.bit_n_HLmem(opcode: nextOpcode, gb: &gb)
        case 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x87,
            0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8F,
            0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x97,
            0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9F,
            0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA7,
            0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAF,
            0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB7,
            0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBF:
            Instruction.res_n_r(opcode: nextOpcode, gb: &gb)
        case 0x86, 0x96, 0xA6, 0xB6, 0x8E, 0x9E, 0xAE, 0xBE:
            Instruction.res_n_HLmem(opcode: nextOpcode, gb: &gb)
        case 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC7,
            0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCF,
            0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD7,
            0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDF,
            0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE7,
            0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEF,
            0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF7,
            0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFF:
            Instruction.set_n_r(opcode: nextOpcode, gb: &gb)
        case 0xC6, 0xD6, 0xE6, 0xF6, 0xCE, 0xDE, 0xEE, 0xFE:
            Instruction.set_n_HLmem(opcode: nextOpcode, gb: &gb)
        default: fatalError()
        }
    }
}
