//
//  PPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 12/7/2568 BE.
//

import Foundation
import DequeModule

struct PPU  {
    enum InterruptType {
        case stat
        case vBlank
    }
    
    typealias InterruptRequestHandler = (InterruptType) -> Void
    
    /// dot cycle : 1 cycle = one of 4 MHz cpu cycle 4 dots = 1 M cycle
    var cycleCounter: UInt16 = 0
    
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
    var backgroundPalette: ColorPaletteRegister = .init(value: 0x0)
    /// same as backgroundPalette ( the lower two bit is ignored because color 0 = transparent  in spiret )
    var spritePalette0: ColorPaletteRegister = .init(value: 0x0)
    /// same as backgroundPalette  ( the lower two bit is ignored because color 0 = transparent  in spiret )
    var spritePalette1: ColorPaletteRegister = .init(value: 0x0)
    
    var frameBuffer = FrameBuffer()
    
    var ppuMode: PPUMode = .mode2(cycleCounter: 0) {
        willSet {
            if newValue.rawValue == ppuMode.rawValue { return }
            switch ppuMode {
            case .mode0:
                lcdStatus.ppuMode = 0
            case .mode1:
                lcdStatus.ppuMode = 1
            case .mode2:
                lcdStatus.ppuMode = 2
            case .mode3:
                lcdStatus.ppuMode = 3
            }
        }
    }
    
    enum FetchType {
        case background
        case sprite(Sprite)
    }
    
    enum PPUMode: RawRepresentable {
        case mode0(cycleCounter: Int)
        case mode1(cycleCounter: Int)
        case mode2(cycleCounter: Int)
        case mode3(cycleCounter: Int, pixelFetcher: PixelFetcher.ScanlineState)
        
        init?(rawValue: Int) {
            fatalError("init with rawValue not supported")
        }
        
        var rawValue: Int {
            switch self {
            case .mode0: 0
            case .mode1: 1
            case .mode2: 2
            case .mode3: 3
            }
        }
    }
    
    var fetchType: FetchType = .background
    var backgroundFIFO: Deque<PixelData> = []
    var spriteFIFO: Deque<PixelData> = []
    var spritesBuffer: Deque<Sprite> = []
    var windowInternalXCounter: UInt8 = 0
    var windowInternalLineCounter: UInt8 = 0
    var windowYCondition: Bool = false
    var windowXCondition: Bool = false
    var isWindowDisplayOnScanline: Bool {
        windowXCondition && windowYCondition && lcdControl.windowEnabled
    }
    var pixelX: UInt8 = 0
    var pixelY: UInt8 = 0
    
    // TODO: - add support for CGB
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0xFF40:
            lcdControl = .init(value)
        case 0xFF41:
            lcdStatus.value = value & 0b1111_1100 | lcdStatus.value & 0b0000_0011
        case 0xFF42:
            scy = value
        case 0xFF43:
            scx = value
        case 0xFF44:
            fatalError("LY is Read Only")
        case 0xFF45:
            lcdYCompare = value & 0x99
        case 0xFF47:
            backgroundPalette = ColorPaletteRegister(value: value)
        case 0xFF48:
            spritePalette0 = ColorPaletteRegister(value: value)
        case 0xFF49:
            spritePalette1 = ColorPaletteRegister(value: value)
        case 0xFF4A:
            wy = value
        case 0xFF4B:
            wx = value
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
        case 0xFF47:
            backgroundPalette.value
        case 0xFF48:
            spritePalette0.value
        case 0xFF49:
            spritePalette1.value
        case 0xFF4A:
            wy
        case 0xFF4B:
            wx
        default: 0xFF
        }
    }
    
    enum AdvanceAction {
        case idle
        case drawFrame(FrameBuffer)
    }
    
    mutating func advance(
        vRam: [UInt8],
        oam: [UInt8],
        interruptRequestHandler: InterruptRequestHandler,
    ) -> AdvanceAction {
        if !lcdControl.lcdDisplayEnabled { return .idle }
        
        handleLCDStatusInterrupt(interruptRequestHandler)
        
        switch ppuMode {
        case let .mode2(cycleCounter):
            if cycleCounter == 0 {
                if !windowYCondition {
                    windowYCondition = wy == lcdY
                }
                
                spritesBuffer = scanSpriteAttributes(atLine: lcdY, fromOAM: oam)
                ppuMode = .mode2(cycleCounter: cycleCounter + 1)
                return .idle
            }
            
            if cycleCounter == 79 {
                let pixelFetcher = PixelFetcher.makeScanlineFetcher()
                
                ppuMode = .mode3(cycleCounter: cycleCounter + 1, pixelFetcher: pixelFetcher)
                return .idle
            }
            ppuMode = .mode2(cycleCounter: cycleCounter + 1)
            return .idle
        case .mode3(let cycleCounter, var pixelFetcher):
            if backgroundFIFO.count > 8, pixelX == 0 {
                let scroll = scx % 8
                if scroll != 0 {
                    backgroundFIFO.removeFirst(Int(scroll))
                }
            }
            
            if backgroundFIFO.count > 8, let backgroundPixel = backgroundFIFO.first {
                if case .background = fetchType {
                    if spriteFIFO.count != 0 {
                        for i in 0..<spriteFIFO.count {
                            if !(spriteFIFO[i].color == 0 || (spriteFIFO[i].backgroundPriority == 1 && backgroundPixel.color != 0)) {
                                if backgroundFIFO.count > i {
                                    backgroundFIFO[i] = spriteFIFO[i]
                                }
                            }
                        }
                        spriteFIFO = []
                    }
                    frameBuffer.value[Int(pixelY) * 160 + Int(pixelX)] = backgroundFIFO.first!.color
                    backgroundFIFO.removeFirst()
                    pixelX += 1
                }
            }
            
            if pixelX > 159 {
                pixelX = 0
                pixelY += 1
                backgroundFIFO = []
                spriteFIFO = []
                spritesBuffer = []
                windowXCondition = false
                ppuMode = .mode0(cycleCounter: cycleCounter + 1)
                return .idle
            }
            
            if pixelX >= wx, !windowXCondition {
                windowXCondition = true
                windowInternalLineCounter += 1
            }
            
            if case .background = fetchType {
                if let spriteIndex = spritesBuffer.firstIndex(where: { sprite in sprite.position.x <= pixelX + 8 }), lcdControl.spriteEnabled {
                    fetchType = .sprite(spritesBuffer[spriteIndex])
                    pixelFetcher.save()
                    pixelFetcher.reset()
                    spritesBuffer.remove(at: spriteIndex)
                }
            }
            
            
            let action = pixelFetcher.advance(delegate: makePixelFetcherDelegate(vRamDataProvider: { vRam[$0] }))
            
            switch action {
            case .idle:
                break;
            case .incrementXCounter:
                if isWindowDisplayOnScanline {
                    windowInternalXCounter &+= 1
                }
                break
            case var .pushPixelRow(pixels):
                switch fetchType {
                case .background:
                    backgroundFIFO.append(contentsOf: pixels)
                case let .sprite(sprite):
                    if sprite.position.x < 8 {
                        let shiftedOutPixelCount = 8 - sprite.position.x
                        pixels.removeFirst(Int(shiftedOutPixelCount))
                    }
                    spriteFIFO.append(contentsOf: pixels)
                    pixelFetcher.restore()
                    fetchType = .background
                }
            }
            ppuMode = .mode3(cycleCounter: cycleCounter + 1, pixelFetcher: pixelFetcher)
            return .idle
        case let .mode0(cycleCounter):
            if cycleCounter == 455 {
                lcdY += 1
                if lcdY == 144 {
                    ppuMode = .mode1(cycleCounter: 0)
                    interruptRequestHandler(.vBlank)
                } else {
                    ppuMode = .mode2(cycleCounter: 0)
                }
                return .idle
            }
            ppuMode = .mode0(cycleCounter: cycleCounter + 1)
            return .idle
            
        case let .mode1(cycleCounter):
            if cycleCounter == 455 {
                lcdY += 1
                if lcdY > 153 {
                    windowXCondition = false
                    windowYCondition = false
                    backgroundFIFO = []
                    spriteFIFO = []
                    spritesBuffer = []
                    windowInternalXCounter = 0
                    windowInternalLineCounter = 0
                    lcdY = 0
                    pixelX = 0
                    pixelY = 0
                    
                    ppuMode = .mode2(cycleCounter: 0)
                    return .drawFrame(frameBuffer)
                }
                ppuMode = .mode1(cycleCounter: 0)
                return .idle
            }
            ppuMode = .mode1(cycleCounter: cycleCounter + 1)
            return .idle
        }
    }
    
    private func handleLCDStatusInterrupt(_ interruptRequestHandler: InterruptRequestHandler) {
        if lcdStatus.mode0, lcdStatus.ppuMode == 0 {
            return interruptRequestHandler(.stat)
        } else if lcdStatus.mode1, lcdStatus.ppuMode == 1 {
            return interruptRequestHandler(.stat)
        } else if lcdStatus.mode2, lcdStatus.ppuMode == 2 {
            return interruptRequestHandler(.stat)
        } else if lcdStatus.lcdYCompare, lcdStatus.lcdYCompareEqual {
            return interruptRequestHandler(.stat)
        }
    }
    
    private func makePixelFetcherDelegate(vRamDataProvider: @escaping (UInt16) -> UInt8) -> PixelFetcherDelegate {
        switch fetchType {
        case .background:
            if isWindowDisplayOnScanline {
                WindowPixelFetcherDelegate(
                    windowInternalXCounter: windowInternalXCounter,
                    windowInternalLineCounter: windowInternalLineCounter,
                    tileMapArea: lcdControl.windowTileMapArea,
                    tileDataArea: lcdControl.tileDataArea,
                    tileNumberProvider: { vRamDataProvider($0) },
                    vRamDataProvider: { vRamDataProvider($0) }
                )
            } else {
                BackgroundPixelFetcherDelegate(
                    scx: scx,
                    scy: scy,
                    lcdY: lcdY,
                    tileMapArea: lcdControl.backgroundTileMapArea,
                    tileDataArea: lcdControl.tileDataArea,
                    tileNumberProvider: { vRamDataProvider($0) },
                    vRamDataProvider: { vRamDataProvider($0) }
                )
            }
        case let .sprite(sprite):
            SpritePixelFetcherDelegate(
                lcdY: lcdY,
                sprite: sprite,
                tileDataArea: 0x8000,
                tileNumberProvider: { vRamDataProvider($0) },
                vRamDataProvider: { vRamDataProvider($0) }
            )
        }
    }
    
    private func scanSpriteAttributes(atLine line: UInt8, fromOAM oam: [UInt8]) -> Deque<Sprite> {
        var currentAddress: UInt16 = 0xFE00
        var buffer: Deque<Sprite> = []
        while buffer.count <= 10, currentAddress <= 0xFE9F {
            let yPosition = oam[currentAddress, offset: 0xFE00]
            let xPosition = oam[currentAddress + 1, offset: 0xFE00]
            let tileNumber = oam[currentAddress + 2, offset: 0xFE00]
            let attributes = oam[currentAddress + 3, offset: 0xFE00]
            let spriteHeight: UInt8 = if lcdControl.spriteSize == 0 { 8 } else { 16 }
            
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
    struct LCDControl {
        let value: UInt8
        /// Bit 7 - set display enable
        
        var lcdDisplayEnabled: Bool { value.bit(7) }
        /// Bit 6 - window tile map area 0 = 9800 - 9BFF, 1 = 9C00 – 9FFF
        var windowTileMapArea: UInt16 {
            if value.bit(6) {
                return 0x9C00
            } else {
                return 0x9800
            }
        }
        /// Bit 5 - set this to false hide window layer entirely
        var windowEnabled: Bool { value.bit(5) }
        /// Bit 4 - tile data area 0 = 8800 – 97FF, 1 = 8000 – 8FFF
        var tileDataArea: UInt16 {
            if value.bit(4) {
                return 0x8000
            } else {
                return 0x8800
            }
        }
        /// Bit 3 - background tile map area 0 = 9800 – 9BFF, 1 = 9C00 – 9FFF
        var backgroundTileMapArea: UInt16 {
            if value.bit(3) {
                0x9C00
            } else {
                0x9800
            }
        }
        /// Bit 2 - sprite size 0 = 8x8 1 = 8x16
        var spriteSize: UInt8 { value.bit(2).toUInt8() }
        /// Bit 1 - if 0 sprite is not drawn on screen
        var spriteEnabled: Bool { value.bit(1) }
        /// Bit 0 - if false background and window layer are not drawn
        var backgroundAndWindowEnalbed: Bool { value.bit(0) }
        
        init(_ value: UInt8) {
            self.value = value
        }
    }
    
    struct Sprite {
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
    
    struct ColorPaletteRegister {
        let value: UInt8
        
        var id0: UInt8 {
            value & 0b0000_0011
        }
        
        var id1: UInt8 {
            (value & 0b0000_1100) >> 2
        }
        
        var id2: UInt8 {
            (value & 0b0011_0000) >> 4
        }
        
        var id4: UInt8 {
            (value & 0b1100_0000) >> 6
        }
    }
}


