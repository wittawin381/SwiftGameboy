//
//  PPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 12/7/2568 BE.
//

import Foundation

struct PictureProcessingUnit {
    typealias InterruptRequestHandler = () -> Void
    
    /// 0xFF40
    var lcdControl: LCDControl = .init(0)
    // TODO: implement LCD Status and interrupt
    /// 0xFF41
    var lcdStatus: LCDStatusRegister = .init(value: 0x0)
    
    /// 0xFF42 background Y off set withint background map
    var scy: UInt8 = 0
    /// 0xFF43 background X off set withint background map
    var scx: UInt8 = 0
    /// LCD Y coordinate means y position or current line which is about to be drawn
    /// value from 0 - 155 -> 0 - 144 for normal line > 144 - 153 means VBlank period
    /// 0xFF44
    var lcdY: UInt8 = 0
    /// if lcdYCompare = lcdY flag in state register is set
    /// 0xFF45
    var lcdYCompare: UInt8 = 0
    /// 0xFF4A window position Y
    var wy: UInt8 = 0
    /// 0xFF4B
    var wx: UInt8 = 0
    
    /// 0xFF47  color shade of each color ID
    /// the color is depend on you
    var backgroundPalette: UInt8 = 0
    /// same as backgroundPalette ( the lower two bit is ignored because color 0 = transparent  in spiret )
    var spritePalette0: UInt8 = 0
    /// same as backgroundPalette  ( the lower two bit is ignored because color 0 = transparent  in spiret )
    var spritePalette1: UInt8 = 0
    
    // TODO: - add support for CGB
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0xFF40:
            lcdControl = .init(value)
        case 0xFF41:
            lcdStatus.value = value
        case 0xFF42:
            scy = value
        case 0xFF43:
            scx = value
        case 0xFF44:
            lcdY = value & 0x99
        case 0xFF45:
            lcdYCompare = value & 0x99
        case 0xFF4A:
            wy = value & 0xA6
        case 0xFF4B:
            wx = value & 0x8F
        default: break
        }
    }
    
    func readValue(at address: UInt16) -> UInt8 {
        return switch address {
        case 0xFF40:
            lcdControl.value
        case 0xFF41:
            lcdStatus.value
        case 0xFF42:
            scy
        case 0xFF43:
            scx
        case 0xFF44:
            lcdY
        case 0xFF45:
            lcdYCompare
        case 0xFF4A:
            wy
        case 0xFF4B:
            wx
        default: 0xFF
        }
    }
    
    func updateTick(vRam: [UInt8], interruptRequestHandler: InterruptRequestHandler) -> [[PixelData]] {
        
        
        
        return []
    }
    
    private func handleLCDStatusInterrupt(interruptRequestHandler: InterruptRequestHandler) {
        if lcdStatus.mode0, lcdStatus.ppuMode == 0 {
            return interruptRequestHandler()
        } else if lcdStatus.mode1, lcdStatus.ppuMode == 1 {
            return interruptRequestHandler()
        } else if lcdStatus.mode2, lcdStatus.ppuMode == 2 {
            return interruptRequestHandler()
        } else if lcdStatus.lcdYCompare, lcdStatus.lcdYCompareEqual {
            return interruptRequestHandler()
        }
    }
    
    private func scanline(_ line: UInt8, vRam: [UInt8]) -> [PixelData] {
        return (0..<160).map { (xPosition: UInt8) in
            let backgroundOrWindowPixel = if lcdControl.windowEnabled, line >= wx, xPosition >= wy - 7 {
                fetchWindowPixel(
                    atLine: line,
                    fromVram: vRam,
                    fetcherX: xPosition,
                    windowX: wx,
                    windowY: wy
                )
            } else {
                fetchBackgroundPixel(
                    atLine: line,
                    fromVram: vRam,
                    fetcherX: xPosition,
                    scx: scx,
                    scy: scy
                )
            }
            
            let spritePixel = fetchSpritePixel(atLine: line, fromVram: vRam, fetcherX: xPosition)
            
            if let spritePixel, spritePixel.backgroundPriority == 0 {
                return spritePixel
            }
            return backgroundOrWindowPixel
        }
    }
    
    private func fetchWindowPixel(atLine line: UInt8, fromVram vRam: [UInt8], fetcherX: UInt8, windowX: UInt8, windowY: UInt8) -> PixelData {
        let tileMapAreaAddress: UInt16 = if lcdControl.windowTileMapArea == 1 {
            0x9C00
        } else {
            0x9800
        }
        let tileNumber = vRam[Int(tileMapAreaAddress + UInt16(windowX) + ((UInt16(windowY) / 8) * 32) + UInt16(fetcherX)) - 0x8000]
        
        let usingUnsignedAddressing = lcdControl.tileDataArea == 1
        let tileDataAreaAddress: UInt16 = if usingUnsignedAddressing {
            0x8000
        } else {
            0x8800
        }
        let tileDataAddress: UInt16 = if usingUnsignedAddressing {
            tileDataAreaAddress + (UInt16(tileNumber) * 16)
        } else {
            tileDataAreaAddress + UInt16(Int16(Int8(bitPattern: tileNumber)) + 128) * 16
        }
        
        let tileYPosition = (windowY % 8) * 2
        let tileDataLow = vRam[Int(tileDataAddress) + Int(tileYPosition) - 0x8000]
        let tileDataHigh = vRam[Int(tileDataAddress) + 1 + Int(tileYPosition) - 0x8000]

        let pixelIndexAtTile = windowX % 8
        let pixelDataLow = tileDataLow.bit(pixelIndexAtTile).toUInt8()
        let pixelDataHigh = tileDataHigh.bit(pixelIndexAtTile).toUInt8()
        
        return PixelData(color: pixelDataHigh << 1 | pixelDataLow,
                         palette: 0,
                         spritePrioriy: 0,
                         backgroundPriority: 0)
    }
    
    private func fetchBackgroundPixel(atLine line: UInt8, fromVram vRam: [UInt8], fetcherX: UInt8, scx: UInt8, scy: UInt8) -> PixelData {
        let tileMapAreaAddress: UInt16 = if lcdControl.backgroundTileMapArea == 1 {
            0x9C00
        } else {
            0x9800
        }
        
        let xOffset: UInt16 = (UInt16(fetcherX) + (UInt16(scx) / 8)) & 0x1F
        let yOffset: UInt16 = (((UInt16(line) + UInt16(scy)) & 0xFF) / 8) * 32
        let tileNumber = vRam[Int(tileMapAreaAddress + yOffset + xOffset) - 0x8000]
        
        let usingUnsignedAddressing = lcdControl.tileDataArea == 1
        let tileDataAreaAddress: UInt16 = if usingUnsignedAddressing {
            0x8000
        } else {
            0x8800
        }
        let tileDataAddress: UInt16 = if usingUnsignedAddressing {
            tileDataAreaAddress + (UInt16(tileNumber) * 16)
        } else {
            tileDataAreaAddress + UInt16(Int16(Int8(bitPattern: tileNumber)) + 128) * 16
        }
        
        let tileYPosition = ((line + scy) % 8) * 2
        let tileDataLow = vRam[Int(tileDataAddress) + Int(tileYPosition) - 0x8000]
        let tileDataHigh = vRam[Int(tileDataAddress) + 1 + Int(tileYPosition) - 0x8000]

        let pixelIndexAtTile = scx % 8
        let pixelDataLow = tileDataLow.bit(pixelIndexAtTile).toUInt8()
        let pixelDataHigh = tileDataHigh.bit(pixelIndexAtTile).toUInt8()
        
        return PixelData(color: pixelDataHigh << 1 | pixelDataLow,
                         palette: 0,
                         spritePrioriy: 0,
                         backgroundPriority: 0)
    }
    
    private func fetchSpritePixel(atLine line: UInt8, fromVram vRam: [UInt8], fetcherX: UInt8) -> PixelData? {
        let sprites = scanSpriteAttributes(atLine: line, fromVram: vRam)
        
        var spriteBuffers: [(UInt8, Sprite)] = []
        for sprite in sprites {
            if sprite.position.x <= fetcherX + 8 {
                let tileNumber = sprite.tileNumber
                let tileDataLow = vRam[0x8000 + Int(tileNumber) * 16]
                let tileDataHigh = vRam[0x8000 + 1 + (Int(tileNumber) * 16)]
                
                let pixelIndexAtTile = UInt8(fetcherX) % 8
                let pixelDataLow = tileDataLow.bit(pixelIndexAtTile).toUInt8()
                let pixelDataHigh = tileDataHigh.bit(pixelIndexAtTile).toUInt8()
                let color = pixelDataHigh << 1 | pixelDataLow
                
        
                spriteBuffers.append((color, sprite))
            }
        }
        let sortedSprite = spriteBuffers.sorted(by: { $0.1.tileNumber < $1.1.tileNumber })
        if let firstSprite = sortedSprite.first {
            return PixelData(color: firstSprite.0,
                             palette: firstSprite.1.attribute.palette.rawValue,
                             spritePrioriy: 0,
                             backgroundPriority: firstSprite.1.attribute.priority.rawValue)
        } else {
            return nil
        }
    }
    
    private func scanSpriteAttributes(atLine line: UInt8, fromVram vRam: [UInt8]) -> [Sprite] {
        var currentAddress: UInt16 = 0xFE00
        var buffer: [Sprite] = []
        while buffer.count <= 10, currentAddress <= 0xFE9F {
            let yPosition = vRam[Int(currentAddress) - 0xFE00]
            let xPosition = vRam[Int(currentAddress) + 1 - 0xFE00]
            let tileNumber = vRam[Int(currentAddress) + 2 - 0xFE00]
            let attributes = vRam[Int(currentAddress) + 3 - 0xFE00]
            let spriteHeight: UInt8 = if lcdControl.spriteSize == 0 { 8 } else { 16 }
            
            if xPosition > 0,
               lcdY + 16 > yPosition,
               lcdY + 16 < yPosition + spriteHeight {
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

extension PictureProcessingUnit {
    struct LCDControl {
        let value: UInt8
        /// Bit 7 - set display enable
        
        var lcdDisplayEnabled: Bool {
            ((value & 0b10000000) >> 7) == 1
        }
        /// Bit 6 - window tile map area 0 = 9800 - 9BFF, 1 = 9C00 – 9FFF
        var windowTileMapArea: Int {
            Int((value & 0b01000000) >> 6)
        }
        /// Bit 5 - set this to false hide window layer entirely
        var windowEnabled: Bool {
            ((value & 0b00100000) >> 5) == 1
        }
        /// Bit 4 - tile data area 0 = 8800 – 97FF, 1 = 8000 – 8FFF
        var tileDataArea: Int {
            Int((value & 0b00010000) >> 4)
        }
        /// Bit 3 - background tile map area 0 = 9800 – 9BFF, 1 = 9C00 – 9FFF
        var backgroundTileMapArea: Int {
            Int((value & 0b00001000) >> 3)
        }
        /// Bit 2 - sprite size 0 = 8x8 1 = 8x16
        var spriteSize: Int {
            Int((value & 0b00000100) >> 2)
        }
        /// Bit 1 - if 0 sprite is not drawn on screen
        var spriteEnabled: Bool {
            ((value & 0b00000010) >> 1) == 1
        }
        /// Bit 0 - if false background and window layer are not drawn
        var backgroundAndWindowEnalbed: Bool {
            (value & 0b00000001) == 1
        }
        
        init(_ value: UInt8) {
            self.value = value
        }
    }
    
    private struct Sprite {
        enum Priority: UInt8 {
            case sprite
            /// background  color 1-3 overlay sprite if color 0 then sprite above
            case background
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
    }
    
    struct LCDStatusRegister {
        var value: UInt8
        
        var ppuMode: UInt8 {
            get { value & 0b0000_0011 }
            set { value = (value & 0b1111_1100) | (newValue & 0b0000_0011) }
        }
        
        var lcdYCompareEqual: Bool {
            get { value.bit(2) }
            set { updateBit(at: 2, value: newValue) }
        }
        
        var mode0: Bool {
            get { value.bit(3) }
            set { updateBit(at: 3, value: newValue) }
        }
        
        var mode1: Bool {
            get { value.bit(4) }
            set { updateBit(at: 4, value: newValue) }
        }
        
        var mode2: Bool {
            get { value.bit(5) }
            set { updateBit(at: 5, value: newValue) }
        }
        
        var lcdYCompare: Bool {
            get { value.bit(6) }
            set { updateBit(at: 6, value: newValue) }
        }
        
        private mutating func updateBit(at index: UInt8, value: Bool) {
            self.value.setBit(at: index, to: value.toUInt8())
        }
    }
}

