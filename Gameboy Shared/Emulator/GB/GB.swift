//
//  Device.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation

public struct GB: ~Copyable, GBKeyEventHandler {
    var cpu: CPU
    var ppu: PPU
    var ioRegisters: IORegisters
    var cartridge: Cartridge
    var internalRam: [UInt8]
    var hRam: [UInt8]
    var bootRom: [UInt8]
    
    var pendingCycles: UInt8 = 0
    
    var renderHandler: (FrameBuffer) -> Void = { _ in }
            
    init(vRamSize: Int,
         internalRamSize: Int,
         cartridge: Cartridge,
         bootRom: [UInt8]
    ) {
        self.cartridge = cartridge
        self.hRam = Array(repeating: 0, count: 127)
        self.internalRam = Array(repeating: 0, count: internalRamSize)
        self.cpu = CPU()
        self.ppu = PPU(vRamSize: vRamSize)
        self.ioRegisters = IORegisters()
        self.bootRom = bootRom
    }
    
    mutating func run() -> PPU.AdvanceAction {
        CPU.run(on: &self)
        ioRegisters.advance()
        return PPU.run(on: &self)
    }
    
    mutating func advance(cycles: UInt8) {
        pendingCycles += cycles
        while pendingCycles >= 1 {
            let action = PPU.run(on: &self)
            switch action {
            case .idle: break
            case .drawFrame(let frameBuffer):
                renderHandler(frameBuffer)
            }
            pendingCycles -= 1
        }
    }
}


