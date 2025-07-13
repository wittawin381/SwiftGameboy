//
//  Device.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation

struct Device {
    var cpu: CPU
    var ppu: PPU
    @Ref var cartridge: Cartridge
    @Ref var vRam: [UInt8]
    @Ref var internalRam: [UInt8]
    @Ref var objectAttributeMemory: [UInt8]
    
    init(vRamSize: Int,
         internalRamSize: Int,
         cartridge: Cartridge
    ) {
        self.cartridge = cartridge
        self.vRam = Array(repeating: 0, count: vRamSize)
        self.internalRam = Array(repeating: 0, count: internalRamSize)
        self.objectAttributeMemory = Array(repeating: 0, count: 160)
        let delegate = MemoryBusDelegate(
            vRam: _vRam.projectedValue,
            internalRam: _internalRam.projectedValue,
            cartridge: _cartridge.projectedValue,
            objectAttributeMemory: _objectAttributeMemory.projectedValue
        )
        self.cpu = CPU(memoryBusDelegate: delegate)
        self.ppu = PPU()
    }
    
    mutating func run() -> PixelRenderer {
        cpu.run()
        return ppu.render(vRam: vRam)
    }
}
