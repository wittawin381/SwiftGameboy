//
//  PPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 12/7/2568 BE.
//

import Foundation
import DequeModule

struct PictureProcessingUnit  {
    enum InterruptType {
        case stat
        case vBlank
    }
    
    typealias InterruptRequestHandler = (InterruptType) -> Void
    typealias DrawHandler = (FrameBuffer) -> Void
    
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
    
    var backgroundFIFO: Deque<UInt8> = []
    var pixelFetcher: PixelFetcher.ScanlineState?
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
//            if value & 0b0000_0111 != lcdStatus.value & 0b0000_0111 {
//                fatalError("ppuMode and LCY == LY is Read only")
//            }
            lcdStatus.value = value & 0b1111_1100 | lcdStatus.value & 0b0000_0011
//            lcdStatus.value = value
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
        interruptRequestHandler: InterruptRequestHandler,
    ) -> AdvanceAction {
        if !lcdControl.lcdDisplayEnabled { return .idle }
        cycleCounter &+= 1
        
        handleLCDStatusInterrupt(interruptRequestHandler)
        
        switch lcdStatus.ppuMode {
        case 2:
            if cycleCounter == 80 {
                if !windowYCondition {
                    windowYCondition = wy == lcdY
                }
                pixelFetcher = PixelFetcher.makeScanlineFetcher()
                
                self.lcdStatus.ppuMode = 3
            }
            return .idle
        case 3:
            if backgroundFIFO.count > 8 {
                if pixelX == 0 {
                    let scroll = scx % 8
                    if scroll != 0 {
                        backgroundFIFO.removeFirst(Int(scroll))
                    }
                }
            }
            if backgroundFIFO.count > 8, let firstPixel = backgroundFIFO.popFirst() {
                frameBuffer.value[Int(pixelY) * 160 + Int(pixelX)] = firstPixel
                pixelX += 1
            }
            
            if pixelX > 159 {
                pixelX = 0
                pixelY += 1
                backgroundFIFO = []
                windowXCondition = false
                self.lcdStatus.ppuMode = 0
                return .idle
            }
            
            if pixelX >= wx, !windowXCondition {
                windowXCondition = true
                windowInternalLineCounter += 1
            }
            
            guard var pixelFetcher else { return .idle }
            
            let action = pixelFetcher.advance { [self] position in
                if isWindowDisplayOnScanline {
                    return (
                        position: PixelFetcher.ScanlineState.Position(
                            x: UInt16(windowInternalXCounter),
                            y: UInt16(windowInternalLineCounter)
                        ),
                        tileMapArea: isWindowDisplayOnScanline ? lcdControl.windowTileMapArea : lcdControl.backgroundTileMapArea,
                        tileDataArea: lcdControl.tileDataArea,
                        vRamProvider: { vRam }
                    )
                } else {
                    return (
                        position: PixelFetcher.ScanlineState.Position(
                            x: UInt16((UInt16(scx) / 8) + position.x) & 0x1F,
                            y: (UInt16(lcdY &+ scy) & 0xFF)
                        ),
                        tileMapArea: isWindowDisplayOnScanline ? lcdControl.windowTileMapArea : lcdControl.backgroundTileMapArea,
                        tileDataArea: lcdControl.tileDataArea,
                        vRamProvider: { vRam }
                    )
                }
            }
            self.pixelFetcher = pixelFetcher
            
            switch action {
            case .idle:
                break;
            case .incrementXCounter:
                if isWindowDisplayOnScanline {
                    windowInternalXCounter += 1
                }
                break
            case let .pushPixelRow(pixels):
                if backgroundFIFO.count <= 8 {
                    backgroundFIFO.append(contentsOf: pixels)
                }
            }
            
            
            
            return .idle
        case 0:
            if cycleCounter == 456 {
                cycleCounter = 0
                lcdY += 1
                if lcdY == 144 {
                    lcdStatus.ppuMode = 1
                } else {
                    lcdStatus.ppuMode = 2
                }
            }
            return .idle
        case 1:
            if cycleCounter == 456 {
                cycleCounter = 0
                lcdY += 1
            }
            if lcdY > 153 {
                windowXCondition = false
                windowYCondition = false
                backgroundFIFO = []
                windowInternalXCounter = 0
                windowInternalLineCounter = 0
                lcdY = 0
                lcdStatus.ppuMode = 2
                pixelX = 0
                pixelY = 0
                return .drawFrame(frameBuffer)
            }
        default: return .idle
        }
        
        return .idle
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
            let yPosition = vRam[currentAddress, offset: 0xFE00]
            let xPosition = vRam[currentAddress + 1, offset: 0xFE00]
            let tileNumber = vRam[currentAddress + 2, offset: 0xFE00]
            let attributes = vRam[currentAddress + 3, offset: 0xFE00]
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

class Ref<Value> {
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}

struct FrameBuffer {
    var ref: Ref<UnsafeMutablePointer<UInt8>>
    
    init() {
        let pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: 160 * 144)
        pixels.update(repeating: 0, count: 160 * 144)
        ref = Ref(pixels)
    }
    
    var value: UnsafeMutablePointer<UInt8> {
        get { ref.value }
        set {
            if !isKnownUniquelyReferenced(&ref) {
                ref = Ref(newValue)
            }
            ref.value = newValue
        }
    }
}


enum PixelFetcher {
    static func makeScanlineFetcher() -> ScanlineState {
        ScanlineState(
            state: .fetchTileNumber(
                cycleCounter: 0
            )
        )
    }
    
    struct ScanlineState {
        var x: UInt16 = 0
        /// 0 - 255
        var y: UInt16 = 0
        
        var state: State
        
        struct Position {
            let x: UInt16
            let y: UInt16
        }
        
        enum State {
            case fetchTileNumber(
                cycleCounter: Int
            )
            
            case fetchTileData(
                vRamProvider: () -> [UInt8],
                tileDataArea: UInt16,
                pixelPosition: Position,
                tileNumber: UInt8,
                usingUnsignedAddressing: Bool,
                cycleCounter: Int
            )
            
            case idle(pixels: [UInt8], cycleCounter: Int)
        }
        
        enum AdvanceAction {
            case idle
            case incrementXCounter
            case pushPixelRow([UInt8])
        }
        
        mutating func advance(delegate: (Position) -> (position: Position, tileMapArea: UInt16, tileDataArea: UInt16, vRamProvider: () -> [UInt8])) -> AdvanceAction {
            switch state {
            case let .fetchTileNumber(
                cycleCounter
            ):
                if cycleCounter < 1 {
                    self.state = .fetchTileNumber(
                        cycleCounter: cycleCounter + 1
                    )
                    return .idle
                }
                let configuration = delegate(Position(x: x, y: y))
                let vRamProvider = configuration.vRamProvider
                let position = configuration.position
                let tileMapArea = configuration.tileMapArea
                let tileDataArea = configuration.tileDataArea
                let vRam = vRamProvider()
                let tileNumber = vRam[(tileMapArea + position.x + (32 * (position.y / 8)) & 0x3FF) - 0x8000]
                
                let usingUnsignedAddressing = tileDataArea == 0x8000
                
                self.state = .fetchTileData(
                    vRamProvider: vRamProvider,
                    tileDataArea: tileDataArea,
                    pixelPosition: position,
                    tileNumber: tileNumber,
                    usingUnsignedAddressing: usingUnsignedAddressing,
                    cycleCounter: 0
                )
                return .idle
            case let .fetchTileData(
                vRamProvider,
                tileDataArea,
                pixelPosition,
                tileNumber,
                usingUnsignedAddressing,
                cycleCounter
            ):
                if cycleCounter < 3 {
                    self.state = .fetchTileData(
                        vRamProvider: vRamProvider,
                        tileDataArea: tileDataArea,
                        pixelPosition: pixelPosition,
                        tileNumber: tileNumber,
                        usingUnsignedAddressing: usingUnsignedAddressing,
                        cycleCounter: cycleCounter + 1
                    )
                    return .idle
                }
                
                let vRam = vRamProvider()
                let tileDataAddress: UInt16 = if usingUnsignedAddressing {
                    tileDataArea + (UInt16(tileNumber) * 16)
                } else {
                    tileDataArea + UInt16(bitPattern: Int16(Int8(bitPattern: tileNumber)) + 128) * 16
                }
                
                let tileAddress = tileDataAddress + (2 * (pixelPosition.y % 8))
                let tileDataLow = vRam[tileAddress - 0x8000]
                let tileDataHigh = vRam[tileAddress + 1 - 0x8000]
                
//                let pixels  = (0..<8).map {
//                    tileDataHigh.bit(7 - $0).toUInt8() << 1 | tileDataLow.bit(7 - $0).toUInt8()
//                }
                var pixels: [UInt8] = []
                for i in 0..<8 {
                    pixels.append((tileDataHigh.bit(7 - i).toUInt8() << 1) | tileDataLow.bit(7 - i).toUInt8())
                }
                
                x += 1
                
                self.state = .idle(pixels: pixels, cycleCounter: 0)
                return .incrementXCounter
            case let .idle(pixels, cycleCounter):
                if cycleCounter < 2 {
                    self.state = .idle(pixels: pixels, cycleCounter: cycleCounter + 1)
                    return .idle
                } else {
                    self.state = .fetchTileNumber(cycleCounter: 0)
                }
                return .pushPixelRow(pixels)
            }
        }
    }
}
