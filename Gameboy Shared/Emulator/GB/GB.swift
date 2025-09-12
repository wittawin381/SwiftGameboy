//
//  Device.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation

public struct GB: GBKeyEventHandler, GBCPUHandler, GBPPUHandler {
    public var cpu: CPU
    internal var ppu: PPU
    internal var ioRegisters: IORegisters
    internal var cartridge: Cartridge
    internal var internalRam: [UInt8]
    internal var hRam: [UInt8]
    internal var bootRom: [UInt8]
    
    private var pendingCycles: UInt8 = 0
    
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
    
    mutating func run() {
        advanceCPU()
    }
    
    public mutating func advance(cycles: UInt8) {
        pendingCycles += cycles
        while pendingCycles > 0 {
            ioRegisters.advance()

            let action = advancePPU()
            switch action {
            case .idle: break
            case .drawFrame(let frameBuffer):
                renderHandler(frameBuffer)
            }
            pendingCycles -= 1
        }
    }
}
