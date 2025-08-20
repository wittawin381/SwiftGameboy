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
    
    init(data: [UInt8], memoryBankController: MemoryBankController) {
        self.data = data
        self.memoryBankController = memoryBankController
    }
    
    init(data: [UInt8]) throws {
        self.data = data
        let cartridgeType = data[0x147]
        let romSize = (1 << data[0x148]) * 32 * 1024
        let ramSize = data[0x149]
        
        switch cartridgeType {
        case 0x00, 0x01, 0x2, 0x3:
            self.memoryBankController = MBCVersion1(
                romSize: romSize,
                ramSize: ramSize
            )
        default:
            fatalError("MBC type \(cartridgeType) not supported")
        }
    }
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        memoryBankController.write(value, at: address)
    }
    
    func readValue(at address: UInt16) -> UInt8 {
        let mappedAddress = memoryBankController.readAddress(for: address)
        return data[Int(mappedAddress)]
//        return data[address]
    }
}
