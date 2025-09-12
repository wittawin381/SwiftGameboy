//
//  PPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 12/7/2568 BE.
//

import Foundation
import DequeModule

public struct PPU  {
    typealias InterruptRequestHandler = (InterruptType) -> Void
    
    enum FetchType {
        case background
        case sprite(Sprite)
    }
    
    enum InterruptType {
        case stat
        case vBlank
    }
    
    var frameBuffer = FrameBuffer()
    var vRam: [UInt8]
    var objectAttributeMemory: [UInt8]
    
    var fetchType: FetchType = .background
    var backgroundFIFO: Deque<PixelData> = []
    var spriteFIFO: Deque<PixelData> = []
    var spritesBuffer: Deque<Sprite> = []
    var windowInternalXCounter: UInt8 = 0
    var windowInternalLineCounter: UInt8 = 255
    var windowYCondition: Bool = false
    var windowXCondition: Bool = false
    var pixelX: UInt8 = 0
    var pixelY: UInt8 = 0
    
    func isWindowDisplayOnScanline(windowEnabled: Bool) -> Bool {
        windowXCondition && windowYCondition && windowEnabled
    }
    
    init(vRamSize: Int) {
        self.vRam = Array(repeating: 0, count: vRamSize)
        self.objectAttributeMemory = Array(repeating: 0, count: 160)
    }
    
    // TODO: - add support for CGB
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0x8000...0x9FFF:
            return vRam[address, offset: 0x8000] = value
        case 0xFE00...0xFE9F:
            return objectAttributeMemory[address, offset: 0xFE00] = value
        default: break
        }
    }
    
    func readValue(at address: UInt16) -> UInt8 {
        return switch address {
        case 0x8000...0x9FFF:
            vRam[address, offset: 0x8000]
        case 0xFE00...0xFE9F:
            objectAttributeMemory[address, offset: 0xFE00]
        default: 0xFF
        }
    }
    
    public enum AdvanceAction {
        case idle
        case drawFrame(FrameBuffer)
    }
    
    func makePixelFetcherDelegate(ioRegisters: borrowing IORegisters) -> PixelFetcherStrategy {
        switch fetchType {
        case .background:
            if isWindowDisplayOnScanline(windowEnabled: ioRegisters.lcdControl.windowEnabled) {
                WindowPixelFetcherStrategy(
                    windowInternalXCounter: windowInternalXCounter,
                    windowInternalLineCounter: windowInternalLineCounter,
                    tileMapArea: ioRegisters.lcdControl.windowTileMapArea,
                    tileDataArea: ioRegisters.lcdControl.tileDataArea
                )
            } else {
                BackgroundPixelFetcherStrategy(
                    scx: ioRegisters.scx,
                    scy: ioRegisters.scy,
                    lcdY: ioRegisters.lcdY,
                    tileMapArea: ioRegisters.lcdControl.backgroundTileMapArea,
                    tileDataArea: ioRegisters.lcdControl.tileDataArea
                )
            }
        case let .sprite(sprite):
            SpritePixelFetcherStrategy(
                lcdY: ioRegisters.lcdY,
                sprite: sprite,
                tileDataArea: 0x8000
            )
        }
    }
    
    func scanSpriteAttributes(atLine line: UInt8, fromOAM oam: borrowing [UInt8], ioRegisters: borrowing IORegisters) -> Deque<Sprite> {
        var currentAddress: UInt16 = 0xFE00
        var buffer: Deque<Sprite> = []
        while buffer.count <= 10, currentAddress <= 0xFE9F {
            let yPosition = oam[currentAddress, offset: 0xFE00]
            let xPosition = oam[currentAddress + 1, offset: 0xFE00]
            let tileNumber = oam[currentAddress + 2, offset: 0xFE00]
            let attributes = oam[currentAddress + 3, offset: 0xFE00]
            let spriteHeight: UInt8 = if ioRegisters.lcdControl.spriteSize == 0 { 8 } else { 16 }
            
            if xPosition > 0,
               line + 16 >= yPosition,
               line + 16 < yPosition + spriteHeight {
                let sprite = Sprite(
                    position: Sprite.Position(x: xPosition, y: yPosition),
                    tileNumber: tileNumber,
                    spriteHeight: spriteHeight,
                    attribute: attributes
                )
                buffer.append(sprite)
            }
            
            currentAddress += 4
        }
        
        return buffer
    }
}

extension PPU {
    struct Sprite {
        let position: Position
        let tileNumber: UInt8
        let spriteHeight: UInt8
        let attribute: Attribute
        
        init(position: Position, tileNumber: UInt8, spriteHeight: UInt8, attribute: UInt8) {
            self.position = position
            self.tileNumber = tileNumber
            self.spriteHeight = spriteHeight
            self.attribute = Attribute(
                priority: attribute.bit(7) ? .background : .sprite,
                yFlip: attribute.bit(6),
                xFlip: attribute.bit(5),
                palette: attribute.bit(4) ? .palette1 : .palette0
            )
        }
        
        enum Priority: UInt8 {
            case sprite = 0
            /// background  color 1-3 overlay sprite if color 0 then sprite above
            case background = 1
        }
        
        enum Palette: UInt8 {
            case palette0
            case palette1
        }
        
        struct Attribute {
            let priority: Priority
            let yFlip: Bool
            let xFlip: Bool
            let palette: Palette
        }
        
        struct Position {
            let x: UInt8
            let y: UInt8
        }
    }
}
