//
//  GB+PPU.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 10/10/2568 BE.
//

import Foundation

enum PPUCycle {
    case enterMode2(cycleCount: Int)
    case cycleMode2(cycleCount: Int)
    case enterMode3(cycleCount: Int)
}

extension GB {
    mutating func advancePPU() -> PPU.AdvanceAction {
        if !ioRegisters.lcdControl.lcdDisplayEnabled { return .idle }
                
        switch ioRegisters.ppuMode {
        case let .mode2(cycleCounter):
            if cycleCounter == 0 {
                if ioRegisters.lcdStatus.mode2 || (ioRegisters.lcdStatus.lcdYCompare && ioRegisters.lcdStatus.lcdYCompareEqual) {
                    ioRegisters.interruptsFlag.set(.lcd)
                }
                
                if !ppu.windowYCondition {
                    ppu.windowYCondition = ioRegisters.wy == ioRegisters.lcdY
                }
                ppu.scanSpriteAttributes(
                    atLine: ioRegisters.lcdY,
                    fromOAM: ppu.objectAttributeMemory,
                    ioRegisters: ioRegisters,
                    into: &ppu.spritesBuffer
                )
                ioRegisters.ppuMode = .mode2(cycleCounter: cycleCounter + 1)
                return .idle
            } else if cycleCounter == 79 {
                let pixelFetcher = PixelFetcher.makeScanlineFetcher()
                
                ioRegisters.ppuMode = .mode3(
                    cycleCounter: cycleCounter + 1,
                    pixelFetcher: pixelFetcher
                )
                return .idle
            }
            ioRegisters.ppuMode = .mode2(cycleCounter: cycleCounter + 1)
            return .idle
        case .mode3(let cycleCounter, var pixelFetcher):
            if ppu.pixelX + 7 >= ioRegisters.wx, !ppu.windowXCondition {
                ppu.windowXCondition = true
                
                if ppu.isWindowDisplayOnScanline(windowEnabled: ioRegisters.lcdControl.windowEnabled) {
                    ppu.backgroundFIFO.removeAll()
                    pixelFetcher.reset()
                    ppu.windowInternalLineCounter &+= 1
                }
            }
            
            if ppu.backgroundFIFO.count > 8, ppu.pixelX == 0, !ppu.isWindowDisplayOnScanline(windowEnabled: ioRegisters.lcdControl.windowEnabled) {
                let scroll = ioRegisters.scx % 8
                if scroll != 0 {
                    ppu.backgroundFIFO.removeFirst(Int(scroll))
                }
            }
            
            if case .background = ppu.fetchType, ppu.backgroundFIFO.count > 8 {
                if !ppu.spriteFIFO.isEmpty {
                    for i in 0..<min(ppu.backgroundFIFO.count, ppu.spriteFIFO.count) {
                        if !(ppu.spriteFIFO[i].color == 0 ||
                             (ppu.spriteFIFO[i].backgroundPriority == 1 &&
                              ppu.backgroundFIFO[i].color != 0)) {
                            ppu.backgroundFIFO[i] = ppu.spriteFIFO[i]
                        }
                    }
                    ppu.spriteFIFO.removeAll()
                }
                ppu.frameBuffer.value[Int(ppu.pixelY) * 160 + Int(ppu.pixelX)] = ppu.backgroundFIFO.dequeue().color;
//                ppu.frameBuffer.value[Int(ppu.pixelY) * 160 + Int(ppu.pixelX)] = ppu.backgroundFIFO.popFirst()?.color ?? 0;
                ppu.pixelX += 1
            }
            
            if case .background = ppu.fetchType {
                if let spriteIndex = ppu.spritesBuffer.firstIndex(where: { sprite in sprite.position.x <= ppu.pixelX + 8 }), ioRegisters.lcdControl.spriteEnabled {
                    ppu.fetchType = .sprite(ppu.spritesBuffer[spriteIndex])
                    pixelFetcher.save()
                    pixelFetcher.reset()
                    ppu.spritesBuffer.remove(at: spriteIndex)
                }
            }
                        
            let action = pixelFetcher.advance(fetchType: ppu.makePixelFetcherDelegate(ioRegisters: ioRegisters), vram: ppu.vRam)
            
            switch action {
            case .idle:
                break
            case .incrementXCounter:
                break
            case var .pushPixelRow(pixels):
                switch ppu.fetchType {
                case .background:
                    if ppu.isWindowDisplayOnScanline(windowEnabled: ioRegisters.lcdControl.windowEnabled) {
                        ppu.windowInternalXCounter &+= 1
                    }
//                    ppu.backgroundFIFO.append(contentsOf: pixels)
                    for pixel in pixels {
                        ppu.backgroundFIFO.enqueue(pixel)
                    }
//                    print(ppu.backgroundFIFO.count)
                case let .sprite(sprite):
                    if sprite.position.x < 8 {
                        let shiftedOutPixelCount = 8 - sprite.position.x
                        pixels.removeFirst(Int(shiftedOutPixelCount))
                    }
                    ppu.spriteFIFO.append(contentsOf: pixels)
                    pixelFetcher.restore()
                    ppu.fetchType = .background
                }
            }
            if ppu.pixelX > 159 {
                ppu.pixelX = 0
                ppu.pixelY += 1
                ppu.backgroundFIFO.removeAll()
                ppu.spriteFIFO.removeAll()
                ppu.spritesBuffer.removeAll()
                ppu.windowInternalXCounter = 0
                ppu.windowXCondition = false
                ppu.fetchType = .background
                ioRegisters.ppuMode = .mode0(cycleCounter: cycleCounter + 1, initial: true)
                return .idle
            }
            ioRegisters.ppuMode = .mode3(cycleCounter: cycleCounter + 1, pixelFetcher: pixelFetcher)
            return .idle
        case let .mode0(cycleCounter, initial):
            if initial {
                ioRegisters.interruptsFlag.set(.lcd)
            }
            
            if cycleCounter == 455 {
                ioRegisters.lcdY += 1
                if ioRegisters.lcdY == 144 {
                    ioRegisters.ppuMode = .mode1(cycleCounter: 0)
                } else {
                    ioRegisters.ppuMode = .mode2(cycleCounter: 0)
                }
                return .idle
            }
            ioRegisters.ppuMode = .mode0(cycleCounter: cycleCounter + 1)
            return .idle
            
        case let .mode1(cycleCounter):
            if cycleCounter == 0 {
                ioRegisters.ppuMode = .mode1(cycleCounter: cycleCounter + 1)
                ioRegisters.interruptsFlag.set(.vBlank)
                ioRegisters.interruptsFlag.set(.lcd)
                return .idle
            } else if cycleCounter == 455 {
                ioRegisters.lcdY += 1
                if ioRegisters.lcdY > 153 {
                    ppu.windowXCondition = false
                    ppu.windowYCondition = false
                    ppu.backgroundFIFO.removeAll()
                    ppu.spriteFIFO.removeAll()
                    ppu.spritesBuffer.removeAll()
                    ppu.windowInternalXCounter = 0
                    ppu.windowInternalLineCounter = 255
                    ioRegisters.lcdY = 0
                    ppu.pixelX = 0
                    ppu.pixelY = 0
                    
                    ioRegisters.ppuMode = .mode2(cycleCounter: 0)
                    return .drawFrame(ppu.frameBuffer)
                }
                ioRegisters.ppuMode = .mode1(cycleCounter: 0)
                return .idle
            } else {
                ioRegisters.ppuMode = .mode1(cycleCounter: cycleCounter + 1)
                return .idle
            }
        }
    }
}
