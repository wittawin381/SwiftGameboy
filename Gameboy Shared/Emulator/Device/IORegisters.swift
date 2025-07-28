//
//  IORegisters.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 16/7/2568 BE.
//

import Foundation

struct IORegisters {
    var bootSuccess: Bool = false
    var ppu: PictureProcessingUnit = PictureProcessingUnit()
    var interrupts: InterruptRegister
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0xFF40...0xFF4B:
            ppu.write(value, at: address)
        case 0xFF50:
            bootSuccess = value == 1
        case 0xFF0F:
            interrupts.value = value
        default:
            break
        }
    }
    
    func readValue(at address: UInt16) -> UInt8 {
        return switch address {
        case 0xFF40...0xFF4B:
            ppu.readValue(at: address)
        case 0xFF0f:
            interrupts.value
        default:
            0xFF
        }
    }
}
