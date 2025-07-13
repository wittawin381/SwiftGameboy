//
//  MemoryBusDelegate.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 12/7/2568 BE.
//

import Foundation

protocol GameboyMemoryBusDelegate {
    mutating func readValue(at address: UInt16) -> UInt8
    mutating func write(_ value: UInt8, to address: UInt16)
}

struct MemoryBusDelegate: GameboyMemoryBusDelegate {
    @RefBinding var vRam: [UInt8]
    @RefBinding var internamRam: [UInt8]
    @RefBinding var cartridge: Cartridge
    @RefBinding var objectAttributeMemory: [UInt8]
    
    init(vRam: RefBinding<[UInt8]>,
         internalRam: RefBinding<[UInt8]>,
         cartridge: RefBinding<Cartridge>,
         objectAttributeMemory: RefBinding<[UInt8]>
    ) {
        self._vRam = vRam
        self._internamRam = internalRam
        self._cartridge = cartridge
        self._objectAttributeMemory = objectAttributeMemory
    }

    mutating func readValue(at address: UInt16) -> UInt8 {
        switch address {
        case 0x0...0x7FFF:
            return cartridge.readValue(at: address)
        case 0x8000...0x9FFF:
            return vRam[Int(address - 0x07FF)]
        case 0xA000...0xFFFF:
            return cartridge.readValue(at: address)
        case 0xC000...0xDFFF:
            return internamRam[Int(address - 0xC000)]
        case 0xFE00...0xFE9F:
            return objectAttributeMemory[Int(address - 0xFE00)]
        // TODO: - implement other space of ram
        default: return 0x0
        }
    }
    
    mutating func write(_ value: UInt8, to address: UInt16) {
        switch address {
        case 0x0...0x7FFF:
            return cartridge.memoryBankController.write(value, at: address)
        case 0x8000...0x9FFF:
            return vRam[Int(address - 0x07FF)] = value
        case 0xA000...0xFFFF:
            return cartridge.memoryBankController.write(value, at: address)
        case 0xC000...0xDFFF:
            return internamRam[Int(address - 0xC000)] = value
        // TODO: - implement other space of ram
        default: break
        }
    }
}
