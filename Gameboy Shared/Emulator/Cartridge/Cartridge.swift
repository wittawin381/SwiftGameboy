//
//  Cartridge.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 12/7/2568 BE.
//

import Foundation

struct Cartridge {
    private var data: [UInt8]
    var memoryBankController: MemoryBankController
    var ram: [UInt8]
    
    init(data: [UInt8]) throws {
        self.data = data
        let cartridgeType = data[0x147]
        let numberOfRomBanks: UInt16 = switch data[0x148] {
        case 0x0: 2
        case 0x1: 4
        case 0x2: 8
        case 0x3: 16
        case 0x4: 32
        case 0x5: 64
        case 0x6: 128
        case 0x7: 256
        case 0x8: 512
        case 0x52: 72
        case 0x53: 80
        case 0x54: 96
        default: 2
        }
        let romSize = (1 << data[0x148]) * 32 * 1024
        let ramSize: UInt32 = switch data[0x149] {
        case 0x0: 0
        case 0x1: 0
        case 0x2: 8 * 1024
        case 0x3: 32 * 1024
        case 0x4: 128 * 1024
        case 0x5: 6 * 1024
        default: 0
        }
        
        ram = Array(repeating: 0, count: Int(ramSize))
        
        switch cartridgeType {
        case 0x00, 0x01, 0x2, 0x3:
            self.memoryBankController = MBCVersion1(
                numberOfRomBanks: numberOfRomBanks,
                romSize: romSize,
                ramSize: ramSize
            )
        default:
            fatalError("MBC type \(cartridgeType) not supported")
        }
    }
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        let action = memoryBankController.write(value, at: address)
        switch action {
        case .writeInternal:
            break
        case let .writeToRam(value, address):
            ram[Int(address)] = value
        }
    }
    
    func readValue(at address: UInt16) -> UInt8 {
        let action = memoryBankController.readAddress(for: address)
        switch action {
        case let .rom(address):
            return data[Int(address)]
        case let .ram(address):
            return ram[Int(address)]
        case .trash:
            return 0xFF
        }
//        return data[address]
    }
}
