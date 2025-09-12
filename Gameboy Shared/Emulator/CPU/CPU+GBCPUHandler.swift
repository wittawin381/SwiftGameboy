//
//  GB+CPU.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 10/10/2568 BE.
//

import Foundation

protocol GBCPUHandler: MemoryHandler {
    var cpu: CPU { get set }
    
    mutating func advanceCPU()
    mutating func handleInterrupt()
    mutating func advance(cycles: UInt8)
}

extension GBCPUHandler {
    mutating func advanceCPU() {
        

        handleInterrupt()
        
        if cpu.isInterruptMasterEnabledRequest {
            cpu.interruptMasterEnabled = true
            cpu.isInterruptMasterEnabledRequest = false
        }

        if !cpu.isHalted {
            let opcode = read(cpu.programCounter)
//            print(String(format:"%x %x", opcode, cpu.programCounter))
            cpu.programCounter += 1
            switch opcode {
            case 0x0:
                Instruction.nop(opcode: opcode, context: &self)
            case 0x01, 0x11, 0x21, 0x31:
                Instruction.ld_rr_a16(opcode: opcode, context: &self)
            case 0x02:
                Instruction.ld_BCmem_A(opcode: opcode, context: &self)
            case 0x12:
                Instruction.ld_DEmem_A(opcode: opcode, context: &self)
            case 0x22:
                Instruction.ld_HLinc_A(opcode: opcode, context: &self)
            case 0x32:
                Instruction.ld_HLdec_A(opcode: opcode, context: &self)
            case 0x03, 0x13, 0x23, 0x33:
                Instruction.inc_rr(opcode: opcode, context: &self)
            case 0x04, 0x14, 0x24:
                Instruction.inc_r(opcode: opcode, context: &self)
            case 0x34:
                Instruction.inc_HLmem(opcode: opcode, context: &self)
            case 0x05, 0x15, 0x25, 0x0D, 0x1D, 0x2D, 0x3D:
                Instruction.dec_r(opcode: opcode, context: &self)
            case 0x35:
                Instruction.dec_HLmem(opcode: opcode, context: &self)
            case 0x06, 0x16, 0x26:
                Instruction.ld_rn(opcode: opcode, context: &self)
            case 0x36:
                Instruction.ld_hlmem_a8(opcode: opcode, context: &self)
            case 0x07:
                Instruction.rlca(opcode: opcode, context: &self)
            case 0x17:
                Instruction.rla(opcode: opcode, context: &self)
            case 0x27:
                Instruction.daa(opcode: opcode, context: &self)
            case 0x37:
                Instruction.scf(opcode: opcode, context: &self)
            case 0x08:
                Instruction.ld_a16mem_sp(opcode: opcode, context: &self)
            case 0x18:
                Instruction.jr_e(opcode: opcode, context: &self)
            case 0x20, 0x28, 0x30, 0x38:
                Instruction.jr_cc_e(opcode: opcode, context: &self)
            case 0x09, 0x19, 0x29, 0x39:
                Instruction.add_HL_rr(opcode: opcode, context: &self)
            case 0x0A:
                Instruction.ld_A_BCmem(opcode: opcode, context: &self)
            case 0x1A:
                Instruction.ld_A_DEmem(opcode: opcode, context: &self)
            case 0x2A:
                Instruction.ld_A_HLinc(opcode: opcode, context: &self)
            case 0x3A:
                Instruction.ld_A_HLdec(opcode: opcode, context: &self)
            case 0x0B, 0x1B, 0x2B, 0x3B:
                Instruction.dec_rr(opcode: opcode, context: &self)
            case 0x0C, 0x1C, 0x2C, 0x3C:
                Instruction.inc_r(opcode: opcode, context: &self)
            case 0x0E, 0x1E, 0x2E, 0x3E:
                Instruction.ld_rn(opcode: opcode, context: &self)
            case 0x0F:
                Instruction.rrca(opcode: opcode, context: &self)
            case 0x1F:
                Instruction.rra(opcode: opcode, context: &self)
            case 0x2F:
                Instruction.cpl(opcode: opcode, context: &self)
            case 0x3F:
                Instruction.ccf(opcode: opcode, context: &self)
            case 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4F,
                0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5F,
                0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6F,
                0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7F:
                Instruction.ld_rr(opcode: opcode, context: &self)
            case 0x46, 0x4E, 0x56, 0x5E, 0x66, 0x6E, 0x7E:
                Instruction.ld_r_hlmem(opcode: opcode, context: &self)
            case 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77:
                Instruction.ld_hlmem_r(opcode: opcode, context: &self)
            case 0x76:
                Instruction.halt(opcode: opcode, context: &self)
            case 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x87:
                Instruction.add_r(opcode: opcode, context: &self)
            case 0x86:
                Instruction.add_HLmem(opcode: opcode, context: &self)
            case 0x8E:
                Instruction.adc_HLmem(opcode: opcode, context: &self)
            case 0x96:
                Instruction.sub_HLmem(opcode: opcode, context: &self)
            case 0x9E:
                Instruction.sbc_HLmem(opcode: opcode, context: &self)
            case 0xA6:
                Instruction.and_HLmem(opcode: opcode, context: &self)
            case 0xAE:
                Instruction.xor_HLmem(opcode: opcode, context: &self)
            case 0xB6:
                Instruction.or_HLmem(opcode: opcode, context: &self)
            case 0xBE:
                Instruction.cp_HLmem(opcode: opcode, context: &self)
            case 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8F:
                Instruction.adc_r(opcode: opcode, context: &self)
            case 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x97:
                Instruction.sub_r(opcode: opcode, context: &self)
            case 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9F:
                Instruction.sbc_r(opcode: opcode, context: &self)
            case 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA7:
                Instruction.and_r(opcode: opcode, context: &self)
            case 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAF:
                Instruction.xor_r(opcode: opcode, context: &self)
            case 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB7:
                Instruction.or_r(opcode: opcode, context: &self)
            case 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBF:
                Instruction.cp_r(opcode: opcode, context: &self)
            case 0xC0, 0xC8, 0xD0, 0xD8:
                Instruction.ret_cc(opcode: opcode, context: &self)
            case 0xD9:
                Instruction.reti(opcode: opcode, context: &self)
            case 0xC1, 0xD1, 0xE1, 0xF1:
                Instruction.pop_rr(opcode: opcode, context: &self)
            case 0xC2, 0xCA, 0xD2, 0xDA:
                Instruction.jp_cc_a16(opcode: opcode, context: &self)
            case 0xC3:
                Instruction.jp_a16(opcode: opcode, context: &self)
            case 0xC4, 0xCC, 0xD4, 0xDC:
                Instruction.call_cc_a16(opcode: opcode, context: &self)
            case 0xC5, 0xD5, 0xE5, 0xF5:
                Instruction.push_rr(opcode: opcode, context: &self)
            case 0xC6:
                Instruction.add_a8(opcode: opcode, context: &self)
            case 0xD6:
                Instruction.sub_a8(opcode: opcode, context: &self)
            case 0xE6:
                Instruction.and_a8(opcode: opcode, context: &self)
            case 0xF6:
                Instruction.or_a8(opcode: opcode, context: &self)
            case 0xC7, 0xCF, 0xD7, 0xDF, 0xE7, 0xEF, 0xF7, 0xFF:
                Instruction.rst_a8(opcode: opcode, context: &self)
            case 0xC9:
                Instruction.ret(opcode: opcode, context: &self)
            case 0xCB:
                Instruction.prefixInstrs(opcode: opcode, context: &self)
            case 0xCD:
                Instruction.call_a16(opcode: opcode, context: &self)
            case 0xCE:
                Instruction.adc_a8(opcode: opcode, context: &self)
            case 0xDE:
                Instruction.sbc_a8(opcode: opcode, context: &self)
            case 0xEE:
                Instruction.xor_a8(opcode: opcode, context: &self)
            case 0xFE:
                Instruction.cp_a8(opcode: opcode, context: &self)
            case 0xE0:
                Instruction.ld_a8mem_A(opcode: opcode, context: &self)
            case 0xE2:
                Instruction.ld_Cmem_A(opcode: opcode, context: &self)
            case 0xE8:
                Instruction.add_sp_e(opcode: opcode, context: &self)
            case 0xE9:
                Instruction.jp_HL(opcode: opcode, context: &self)
            case 0xEA:
                Instruction.ld_a16mem_A(opcode: opcode, context: &self)
            case 0xF0:
                Instruction.ld_A_a8mem(opcode: opcode, context: &self)
            case 0xF2:
                Instruction.ld_A_Cmem(opcode: opcode, context: &self)
            case 0xF3:
                Instruction.di(opcode: opcode, context: &self)
            case 0xF8:
                Instruction.ld_hl_spe(opcode: opcode, context: &self)
            case 0xF9:
                Instruction.ld_sp_hl(opcode: opcode, context: &self)
            case 0xFA:
                Instruction.ld_A_a16mem(opcode: opcode, context: &self)
            case 0xFB:
                Instruction.ei(opcode: opcode, context: &self)
            default:
                fatalError()
            }
        } else {
            advance(cycles: 1)
        }
    }
    
    mutating func handleInterrupt() {
        var interruptFlag = InterruptRegister(value: read(0xFF0F))
        
        if cpu.interruptEnable.value & interruptFlag.value != 0 {
            cpu.isHalted = false
        }

        guard cpu.interruptMasterEnabled else { return }
                
        if let respondedInterrupt = interruptFlag.findFirstRespondedInterrupt(using: cpu.interruptEnable) {
            cpu.stackPointer -= 1
            write(UInt8(cpu.programCounter >> 8), to: cpu.stackPointer)
            cpu.stackPointer -= 1
            write(UInt8(cpu.programCounter & 0xFF), to: cpu.stackPointer)
            cpu.programCounter = respondedInterrupt.address
            
            interruptFlag.unset(respondedInterrupt)
            cpu.interruptMasterEnabled = false
            write(interruptFlag.value, to: 0xFF0F)
        }
    }
}
