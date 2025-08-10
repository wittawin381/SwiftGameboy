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
    
    mutating func run() -> PictureProcessingUnit.AdvanceAction {
        cpu.update { [cpu] address in
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
                return cpu.instructionRegister
            default: return 0xFF
            }
            
        }
        writeMemory: { value, address in
            switch address {
            case 0x0...0x7FFF:
                return cartridge.memoryBankController.write(value, at: address)
            case 0x8000...0x9FFF:
                
                if address >= 0x9800, address <= 0x9BFF {
                    print("HEE")
                    if address == 0x9800, value != 0 {
                        print("DD")
                    }
                }
                return vRam[address, offset: 0x8000] = value
            case 0xA000...0xBFFF:
                return cartridge.memoryBankController.write(value, at: address)
            case 0xC000...0xDFFF:
                return internalRam[address, offset: 0xC000] = value
            case 0xFE00...0xFE9F:
                return objectAttributeMemory[address, offset: 0xFE00] = value
            case 0xFF00...0xFF7F:
                return ioRegisters.write(value, at: address)
            case 0xFF80...0xFFFE:
                return hRam[address, offset: 0xFF80] = value
            // TODO: - implement other space of ram
            default: break
            }
        }
        
        return ioRegisters.ppu.advance(
            vRam: vRam,
            interruptRequestHandler: { type in
                
            })
    }
}
