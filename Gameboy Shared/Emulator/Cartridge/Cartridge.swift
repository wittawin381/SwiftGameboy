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
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        memoryBankController.write(value, at: address)
    }
    
    mutating func readValue(at address: UInt16) -> UInt8 {
        let mappedAddress = memoryBankController.readAddress(for: address)
        return data[Int(mappedAddress)]
    }
}
