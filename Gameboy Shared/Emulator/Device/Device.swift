//
//  Device.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation

struct Device {
    var cpu: CPU
    var ioRegisters: IORegisters
    var cartridge: Cartridge
    var vRam: [UInt8]
    var internalRam: [UInt8]
    var hRam: [UInt8]
    var objectAttributeMemory: [UInt8]
    
    var bootRom: [UInt8]
    
    var dmaTransferStart: Bool = false
    var dmaStartAddress: UInt16 = 0x0
    
    init(vRamSize: Int,
         internalRamSize: Int,
         cartridge: Cartridge,
         bootRom: [UInt8]
    ) {
        self.cartridge = cartridge
        self.vRam = Array(repeating: 0, count: vRamSize)
        self.hRam = Array(repeating: 0, count: 127)
        self.internalRam = Array(repeating: 0, count: internalRamSize)
        self.objectAttributeMemory = Array(repeating: 0, count: 160)
        self.cpu = CPU()
        self.ioRegisters = IORegisters()
        self.bootRom = bootRom
    }
    
    mutating func dmaTransfer(sourceAddress: UInt16) {
        for i in 0...0x9F {
            objectAttributeMemory[i] = readValue(at: sourceAddress + UInt16(i))
        }
    }
    
    func readValue(at address: UInt16) -> UInt8 {
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
            return vRam[address, offset: 0x8000]
        case 0xA000...0xBFFF:
            return cartridge.readValue(at: address)
        case 0xC000...0xDFFF:
            return internalRam[address, offset: 0xC000]
        case 0xFE00...0xFE9F:
            return objectAttributeMemory[address, offset: 0xFE00]
        case 0xFF00...0xFF7F:
            return ioRegisters.readValue(at: address)
        case 0xFF80...0xFFFE:
            return hRam[address, offset: 0xFF80]
//        case 0xFFFF:
//            return cpu.interruptEnable.value
        default: return 0xFF
        }
    }
    
    mutating func run() -> PPU.AdvanceAction {
        withUnsafeMutablePointer(to: &cpu) { cpu in
            cpu.pointee.advance { address in
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
                    return vRam[address, offset: 0x8000]
                case 0xA000...0xBFFF:
                    return cartridge.readValue(at: address)
                case 0xC000...0xDFFF:
                    return internalRam[address, offset: 0xC000]
                case 0xFE00...0xFE9F:
                    return objectAttributeMemory[address, offset: 0xFE00]
                case 0xFF00...0xFF7F:
                    return ioRegisters.readValue(at: address)
                case 0xFF80...0xFFFE:
                    return hRam[address, offset: 0xFF80]
                case 0xFFFF:
                    return cpu.pointee.interruptEnable.value
                default: return 0xFF
                }
            }
            writeMemory: { value, address in
                switch address {
                case 0x0...0x7FFF:
                    return cartridge.memoryBankController.write(value, at: address)
                case 0x8000...0x9FFF:
                    return vRam[address, offset: 0x8000] = value
                case 0xA000...0xBFFF:
                    return cartridge.memoryBankController.write(value, at: address)
                case 0xC000...0xDFFF:
                    return internalRam[address, offset: 0xC000] = value
                case 0xFE00...0xFE9F:
                    return objectAttributeMemory[address, offset: 0xFE00] = value
                case 0xFF00...0xFF7F:
                    if address == 0xFF46 {
                        let dmaSourceAddress = UInt16(value) << 8
                        dmaTransferStart = true
                        dmaStartAddress = dmaSourceAddress
//                        dmaTransfer(sourceAddress: dmaSourceAddress)
                    }
                    return ioRegisters.write(value, at: address)
                case 0xFF80...0xFFFE:
                    return hRam[address, offset: 0xFF80] = value
                case 0xFFFF:
                    return cpu.pointee.interruptEnable.value = value
                default: break
                }
            }
        }
        
        if dmaTransferStart {
            dmaTransfer(sourceAddress: dmaStartAddress)
            dmaTransferStart = false
            dmaStartAddress = 0x0
        }
        
        ioRegisters.advance()

        return ioRegisters.ppu.advance(
            vRam: vRam,
            oam: objectAttributeMemory,
            interruptRequestHandler: { type in
                switch type {
                case .stat:
                    ioRegisters.interruptsFlag.set(.lcd)
                case .vBlank:
                    ioRegisters.interruptsFlag.set(.vBlank)
                }
            })
    }
}
