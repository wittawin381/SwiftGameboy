//
//  PixelFetcher.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 11/8/2568 BE.
//

import Foundation

enum PixelFetcher {
    static func makeScanlineFetcher() -> ScanlineState {
        ScanlineState(state: .fetchTileNumber)
    }
    
    enum AdvanceAction {
        case idle
        case incrementXCounter
        case pushPixelRow([PixelData])
    }
    
    enum FetchType {
        case background(
            scx: UInt8,
            scy: UInt8,
            lcdY: UInt8,
            tileMapArea: UInt16,
            tileDataArea: UInt16,
        )
        
        case window(
            windowInternalXCounter: UInt8,
            windowInternalLineCounter: UInt8,
            tileMapArea: UInt16,
            tileDataArea: UInt16,
        )
        
        case sprite(
            lcdY: UInt8,
            sprite: PPU.Sprite,
        )
        
        var tileDataArea: UInt16 {
            switch self {
            case .background(_, _, _, _, let tileDataArea):
                tileDataArea
            case .window(_, _, _, let tileDataArea):
                tileDataArea
            case .sprite(_, _):
                0x8000
            }
        }
        
        var tileDataOffset: UInt16 {
            switch self {
            case .background(_, let scy, let lcdY, _, _):
                return 2 * ((UInt16(lcdY) &+ UInt16(scy)) % 8)
            case .window(_, let windowInternalLineCounter, _, _):
                return 2 * (UInt16(windowInternalLineCounter) % 8)
            case .sprite(let lcdY, let sprite):
                if sprite.attribute.yFlip {
                    let line = UInt16(lcdY + 16 - sprite.position.y)
                    if line > 7 {
                        return 2 * (UInt16(15 - line) % 8)
                    } else {
                        return 2 * (UInt16(7 - line) % 8)
                    }
                } else {
                    return 2 * (UInt16(lcdY + 16 - sprite.position.y) % 8)
                }
            }
        }
        
        func fetchTileNumberFor(
            position: PixelFetcher.ScanlineState.Position,
            from vram: borrowing [UInt8]
        ) -> UInt8 {
            switch self {
            case .background(let scx, let scy, let lcdY, let tileMapArea, _):
                let position = PixelFetcher.ScanlineState.Position(
                    x: UInt16((UInt16(scx) / 8) + position.x) & 0x1F,
                    y: (UInt16(lcdY &+ scy) & 0xFF)
                )
                return vram[(tileMapArea + position.x + (32 * (position.y / 8)) & 0x3FF) - 0x8000]
            case .window(let windowInternalXCounter, let windowInternalLineCounter, let tileMapArea, _):
                let position = PixelFetcher.ScanlineState.Position(
                    x: UInt16(windowInternalXCounter),
                    y: UInt16(windowInternalLineCounter)
                )
                return vram[(tileMapArea + position.x + (32 * (position.y / 8)) & 0x3FF) - 0x8000]
            case .sprite(let lcdY, let sprite):
                if sprite.spriteHeight == 16 {
                    let line = UInt16(lcdY + 16 - sprite.position.y)
                    let isSecondHalf: Bool = (line > 7)
                    
                    /// top tile number is first 7 bit only and bottom tile number is first 7 bit + 1
                    return sprite.tileNumber & 0b1111_1110 | (sprite.attribute.yFlip == isSecondHalf ? 0 : 1)
                }
                return sprite.tileNumber
            }
        }
        
        func fetchPixelDataFrom(
            tileDataAddress: UInt16,
            vram: borrowing [UInt8]
        ) -> [PixelData] {
            let tileAddress = tileDataAddress + tileDataOffset
            let tileDataLow = vram[tileAddress - 0x8000]
            let tileDataHigh = vram[tileAddress + 1 - 0x8000]
            var pixels: [PixelData] = []

            switch self {
            case .background, .window:
                for i in 0..<8 {
                    let color = (tileDataHigh.bit(7 - i).toUInt8() << 1) | tileDataLow.bit(7 - i).toUInt8()
                    let pixel = PixelData(
                        color: color,
                        palette: 0,
                        spritePrioriy: 0,
                        backgroundPriority: 0)
                    pixels.append(pixel)
                }
                return pixels
            case .sprite(_, let sprite):
                if sprite.attribute.xFlip {
                    for i in 0..<8 {
                        let color = (tileDataHigh.bit(i).toUInt8() << 1) | tileDataLow.bit(i).toUInt8()
                        let pixel = PixelData(
                            color: color,
                            palette: 0,
                            spritePrioriy: 0,
                            backgroundPriority: sprite.attribute.priority.rawValue)
                        pixels.append(pixel)
                    }
                    
                } else {
                    for i in 0..<8 {
                        let color = (tileDataHigh.bit(7 - i).toUInt8() << 1) | tileDataLow.bit(7 - i).toUInt8()
                        let pixel = PixelData(
                            color: color,
                            palette: 0,
                            spritePrioriy: 0,
                            backgroundPriority: sprite.attribute.priority.rawValue)
                        pixels.append(pixel)
                    }
                }
                return pixels
            }
        }
    }
    
    struct ScanlineState {
        struct Snapshot {
            var x: UInt16 = 0
            var y: UInt16 = 0
        }
        
        var x: UInt16 = 0
        var y: UInt16 = 0
        
        var pendingCycle: UInt8 = 1
        var state: State
        
        private var snapshot: Snapshot? = nil
        
        init(state: State, snapshot: Snapshot? = nil) {
            self.state = state
            self.snapshot = snapshot
        }
        
        struct Position {
            let x: UInt16
            let y: UInt16
        }
        
        enum State {
            case fetchTileNumber
            
            case fetchTileData(
                tileNumber: UInt8,
                usingUnsignedAddressing: Bool
            )
            
            case idle(pixels: [PixelData])
        }
        
        mutating func advance(
            fetchType: FetchType,
            vram: borrowing [UInt8]
        ) -> AdvanceAction {
            if pendingCycle > 0 {
                pendingCycle -= 1
                return .idle
            }
            switch state {
            case .fetchTileNumber:
                let tileNumber = fetchType.fetchTileNumberFor(
                    position: Position(x: x, y: y),
                    from: vram
                )
                
                let tileDataArea = fetchType.tileDataArea
                let usingUnsignedAddressing = tileDataArea == 0x8000 || tileDataArea == 0x9000
                
                pendingCycle = 3
                self.state = .fetchTileData(
                    tileNumber: tileNumber,
                    usingUnsignedAddressing: usingUnsignedAddressing
                )
                return .idle
            case let .fetchTileData(
                tileNumber,
                usingUnsignedAddressing
            ):
                let tileDataArea = fetchType.tileDataArea
                
                let tileDataAddress: UInt16 = if usingUnsignedAddressing {
                    tileDataArea + (UInt16(tileNumber) * 16)
                } else {
                    tileDataArea + (UInt16((UInt8(bitPattern: Int8(bitPattern: tileNumber)) &+ 128)) * 16)
                }
                
                let pixels = fetchType.fetchPixelDataFrom(tileDataAddress: tileDataAddress, vram: vram)
                
                pendingCycle = 1
                self.state = .idle(pixels: pixels)
                return .incrementXCounter
            case let .idle(pixels):
                pendingCycle = 1
                self.state = .fetchTileNumber
                x += 1

                return .pushPixelRow(pixels)
            }
        }
        
        mutating func restore() {
            guard let snapshot else { return }
            self.x = snapshot.x
            self.state = .fetchTileNumber
            self.snapshot = nil
        }
        
        mutating func save() {
            let snapshot = Snapshot(x: x)
            self.snapshot = snapshot
        }
        
        mutating func reset() {
            x = 0
            y = 0
            state = .fetchTileNumber
        }
    }
}

