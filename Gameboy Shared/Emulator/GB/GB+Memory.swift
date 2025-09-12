//
//  GBState+Memory.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 11/9/2568 BE.
//

import Foundation

public protocol MemoryHandler {
    func read(_ address: UInt16) -> UInt8
    mutating func write(_ value: UInt8, to address: UInt16)
}

extension GB {
    private mutating func dmaTransfer(sourceAddress: UInt16) {
        for i in 0...0x9F {
            ppu.objectAttributeMemory[i] = read(sourceAddress + UInt16(i))
        }
    }
    
    public func read(_ address: UInt16) -> UInt8 {
        switch address {
        case 0x0...0x7FFF:
            if ioRegisters.bootSuccess {
                return cartridge.readValue(at: address)
            } else {
                switch address {
                case 0x0...0xFF:
                    return bootRom[address]
                case 0x100...0x7FFF:
                    return cartridge.readValue(at: address)
                default: return 0xFF
                }
            }
        case 0x8000...0x9FFF:
            return ppu.readValue(at: address)
        case 0xA000...0xBFFF:
            return cartridge.readValue(at: address)
        case 0xC000...0xDFFF:
            return internalRam[address, offset: 0xC000]
        case 0xFE00...0xFE9F:
            return ppu.readValue(at: address)
        case 0xFF00...0xFF7F:
            return ioRegisters.readValue(at: address)
        case 0xFF80...0xFFFE:
            return hRam[address, offset: 0xFF80]
        case 0xFFFF:
            return cpu.interruptEnable.value
        default: return 0xFF
        }
    }
    
    public mutating func write(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x0...0x7FFF:
            return cartridge.write(value, at: address)
        case 0x8000...0x9FFF:
            return ppu.write(value, at: address)
        case 0xA000...0xBFFF:
            return cartridge.write(value, at: address)
        case 0xC000...0xDFFF:
            return internalRam[address, offset: 0xC000] = value
        case 0xFE00...0xFE9F:
            return ppu.write(value, at: address)
        case 0xFF00...0xFF7F:
            if address == 0xFF46 {
                let dmaSourceAddress = UInt16(value) << 8
                return dmaTransfer(sourceAddress: dmaSourceAddress)
            }
            return ioRegisters.write(value, at: address)
        case 0xFF80...0xFFFE:
            return hRam[address, offset: 0xFF80] = value
        case 0xFFFF:
            return cpu.interruptEnable.value = value
        default: break
        }
    }
}
