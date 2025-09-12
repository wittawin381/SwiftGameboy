//
//  MemoryBankController.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 10/7/2568 BE.
//

import Foundation

protocol MemoryBankController {
    var romSize: Int { get }
    var ramSize: UInt32 { get }
    
    /// ram bank register is actually 2 bit register
    var additionalRegister: UInt8 { get set }
    /// 5 bit rom bank number to support bank from 01-7F (128 banks)
    /// when it need more than 5 bit to access rom number it use 2 bit from the additional regiser above
    var romBankNumberRegister: UInt8 { get set }
    
    var ramEnabled: Bool { get set }
    
    mutating func write(_ value: UInt8, at address: UInt16) -> MemoryBankControllerWriteAction
    func readAddress(for address: UInt16) -> MemoryBankControllerAddress
}

enum MemoryBankControllerWriteAction {
    case writeInternal
    case writeToRam(value: UInt8, address: UInt32)
}

enum MemoryBankControllerAddress {
    case rom(address: UInt32)
    case ram(address: UInt32)
    case trash
}

struct MBCVersion1: MemoryBankController {
    let numberOfRomBanks: UInt16
    let romSize: Int
    let ramSize: UInt32
    
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
    
    var bitmask: UInt8 {
        switch numberOfRomBanks {
        case 2: 0b00000001
        case 4: 0b00000011
        case 8: 0b00000111
        case 16: 0b00001111
        case 32, 64, 128: 0b00011111
        default: 0b00000001
        }
    }
    
    func readAddress(for address: UInt16) -> MemoryBankControllerAddress {
        switch address {
        /// fixed ROM bank 0 (read-only)
        case 0x0...0x3FFF:
            switch bankingMode {
            case .simple:
                return .rom(address: UInt32(address))
            case .advanced:
                if numberOfRomBanks <= 32 {
                    return .rom(address: UInt32((address)))
                }
                if numberOfRomBanks == 64 {
                    let zeroBankNumber = (UInt32(additionalRegister) & 0x1) << 5
                    return .rom(address: (0x4000 * zeroBankNumber) + UInt32(address))
                }
                
                if numberOfRomBanks == 128 {
                    let zeroBankNumber = (UInt32(additionalRegister) & 0x3) << 5
                    return .rom(address: (0x4000 * zeroBankNumber) + UInt32(address))
                }
            }
        /// ROM bank 01-7F (read-only)
        case 0x4000...0x7FFF:
            if numberOfRomBanks <= 32 {
                let highBankNumber = UInt32(romBankNumberRegister & bitmask)
                return .rom(address: 0x4000 * highBankNumber + UInt32(address) - 0x4000)
            }
            
            if numberOfRomBanks == 64 {
                let highBankNumber = (UInt32(additionalRegister) & 0x1) << 5  | UInt32(romBankNumberRegister & bitmask)
                return .rom(address: 0x4000 * highBankNumber + UInt32(address) - 0x4000)
            }
            
            if numberOfRomBanks == 128 {
                let highBankNumber = (UInt32(additionalRegister) & 0x3) << 5  | UInt32(romBankNumberRegister & bitmask)
                return .rom(address: 0x4000 * highBankNumber + UInt32(address) - 0x4000)
            }
        /// RAM bank
        case 0xA000...0xBFFF:
            if !ramEnabled {
                return .trash
            }
            
            if ramSize <= 8192 {
                return .ram(address: UInt32(UInt32(address - 0xA000) % ramSize))
            }
            
            let memoryAddress = switch bankingMode {
            case .simple:
                address
            case .advanced:
                (0x2000 * UInt16(additionalRegister)) + (address - 0xA000)
            }
            return .ram(address: UInt32(memoryAddress - 0xA000))
        default: return .trash
        }
        return .trash
    }
    
    mutating func write(_ value: UInt8, at address: UInt16) -> MemoryBankControllerWriteAction {
        switch (address) {
        case 0x0...0x1FFF:
            ramEnabled = value == 0xA
            return .writeInternal
        case 0x2000...0x3FFF:
            var romBankValue = value & bitmask
            if ~romBankValue == 0 {
                romBankValue += 1
            }
            romBankNumberRegister = romBankValue
            return .writeInternal
        case 0x4000...0x5FFF:
            additionalRegister = value & 0x3
            return .writeInternal
        case 0x6000...0x7FFF:
            bankingMode = (value & 0x1) == 0 ? .simple : .advanced
            return .writeInternal
        case 0xA000...0xBFFF:
            if ramEnabled {
                if ramSize <= 8192 {
                    let address = UInt32(UInt32(address - 0xA000) % ramSize)
                    return .writeToRam(value: value, address: address)
                }
                
                let memoryAddress = switch bankingMode {
                case .simple:
                    address
                case .advanced:
                    (0x2000 * UInt16(additionalRegister)) + (address - 0xA000)
                }
                let address = UInt32(memoryAddress - 0xA000)
                return .writeToRam(value: value, address: address)
            }
        default: break
        }
        return .writeInternal
    }
}

