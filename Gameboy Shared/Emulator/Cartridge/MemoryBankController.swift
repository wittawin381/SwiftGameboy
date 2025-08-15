//
//  MemoryBankController.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 10/7/2568 BE.
//

import Foundation

protocol MemoryBankController {
    var romSize: Int { get }
    var ramSize: UInt8 { get }
    
    /// ram bank register is actually 2 bit register
    var additionalRegister: UInt8 { get set }
    /// 5 bit rom bank number to support bank from 01-7F (128 banks)
    /// when it need more than 5 bit to access rom number it use 2 bit from the additional regiser above
    var romBankNumberRegister: UInt8 { get set }
    
    var ramEnabled: Bool { get set }
    
    mutating func write(_ value: UInt8, at address: UInt16)
    func readAddress(for address: UInt16) -> UInt32
}

struct MBCVersion1: MemoryBankController {
    let romSize: Int
    let ramSize: UInt8
    
    var additionalRegister: UInt8 = 0
    var bankingMode: BankingMode = .simple
    var romBankNumberRegister: UInt8 = 0
    var ramEnabled: Bool = false
    
    let romBankOffset: UInt16 = 0x4000
    let ramBankOffset: UInt16 = 0x2000
    
    enum BankingMode: Int {
        case simple
        case advanced
    }
    
    func readAddress(for address: UInt16) -> UInt32 {
        switch address {
        /// fixed ROM bank 0 (read-only)
        case 0x0...0x3FFF:
            let memoryAddress = switch bankingMode {
            case .simple:
                address
            case .advanced:
                (UInt16(additionalRegister) * romBankOffset) + address
            }
            return UInt32(memoryAddress)
        /// ROM bank 01-7F (read-only)
        case 0x4000...0x7FFF:
            let adjustedRomBankNumber = romBankNumberRegister == 0 ? 1 : romBankNumberRegister
            let combinedRomBankNumber: UInt32 = (UInt32(additionalRegister) << 5) | UInt32(adjustedRomBankNumber)
            let memoryAddress: UInt32 = UInt32((combinedRomBankNumber * UInt32(romBankOffset)) + UInt32(address) - 0x4000)
            return memoryAddress
        /// RAM bank
        case 0xA000...0xBFFF:
            if !ramEnabled {
                return 0xFF
            }
            let memoryAddress = switch bankingMode {
            case .simple:
                address
            case .advanced:
                UInt16(romSize) + (UInt16(additionalRegister) * ramBankOffset) + address
            }
            return UInt32(memoryAddress)
        default: return 0xFF;
        }
    }
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch (address) {
        case 0x0...0x1FFF:
            return ramEnabled = value == 0xA
        case 0x2000...0x3FFF:
            var romBankValue = value & 0x1F
            if romBankValue == 0 {
                romBankValue += 1
            }
            if romBankValue > romSize / 16 {
                romBankValue &= UInt8((romSize / 16))
            }
            if romBankValue == 22 {
                print("ROM EXCEED")
            }
//            return romBankNumberRegister = romBankValue
        case 0x4000...0x5FFF:
            if romSize < 1024 * 1024 { return }
            return additionalRegister = value & 0x3
        case 0x6000...0x7FFF:
            return bankingMode = (value & 0x1) == 0 ? .simple : .advanced
        default: break
        }
    }
}

