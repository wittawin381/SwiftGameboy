//
//  PixelFetcher.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 11/8/2568 BE.
//

import Foundation

enum PixelFetcher {
    static func makeScanlineFetcher() -> ScanlineState {
        ScanlineState(
            state: .fetchTileNumber(
                cycleCounter: 0
            )
        )
    }
    
    struct Snapshot {
        var x: UInt16 = 0
        var y: UInt16 = 0
    }
    
    struct ScanlineState {
        var x: UInt16 = 0
        var y: UInt16 = 0
        
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
            case fetchTileNumber(
                cycleCounter: Int
            )
            
            case fetchTileData(
                tileDataArea: UInt16,
                pixelDataFetcher: (UInt16) -> [PixelData],
                tileNumber: UInt8,
                usingUnsignedAddressing: Bool,
                cycleCounter: Int
            )
            
            case idle(pixels: [PixelData], cycleCounter: Int)
        }
        
        enum AdvanceAction {
            case idle
            case incrementXCounter
            case pushPixelRow([PixelData])
        }
        
        mutating func advance(delegate: PixelFetcherDelegate) -> AdvanceAction {
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
                
                let tileNumber = delegate.pixelFetcherTileNumberFor(fetcherPosition: Position(x: x, y: y))
                
                let usingUnsignedAddressing = delegate.tileDataArea == 0x8000 || delegate.tileDataArea == 0x9000
                
                self.state = .fetchTileData(
                    tileDataArea: delegate.tileDataArea,
                    pixelDataFetcher: delegate.pixelFetcherTileDataFor(tileDataAddress:),
                    tileNumber: tileNumber,
                    usingUnsignedAddressing: usingUnsignedAddressing,
                    cycleCounter: 0
                )
                return .idle
            case let .fetchTileData(
                tileDataArea,
                pixelDataFetcher,
                tileNumber,
                usingUnsignedAddressing,
                cycleCounter
            ):
                if cycleCounter < 3 {
                    self.state = .fetchTileData(
                        tileDataArea: tileDataArea,
                        pixelDataFetcher: pixelDataFetcher,
                        tileNumber: tileNumber,
                        usingUnsignedAddressing: usingUnsignedAddressing,
                        cycleCounter: cycleCounter + 1
                    )
                    return .idle
                }
                
                let tileDataAddress: UInt16 = if usingUnsignedAddressing {
                    tileDataArea + (UInt16(tileNumber) * 16)
                } else {
                    tileDataArea + (UInt16((UInt8(bitPattern: Int8(bitPattern: tileNumber)) &+ 128)) * 16)
                }
                
                let pixels = pixelDataFetcher(tileDataAddress)
                
                
                self.state = .idle(pixels: pixels, cycleCounter: 0)
                return .incrementXCounter
            case let .idle(pixels, cycleCounter):
                if cycleCounter < 2 {
                    self.state = .idle(pixels: pixels, cycleCounter: cycleCounter + 1)
                    return .idle
                } else {
                    self.state = .fetchTileNumber(cycleCounter: 0)
                }
                x += 1

                return .pushPixelRow(pixels)
            }
        }
        
        mutating func restore() {
            guard let snapshot else { return }
            self.x = snapshot.x
            self.state = .fetchTileNumber(cycleCounter: 0)
            self.snapshot = nil
        }
        
        mutating func save() {
            let snapshot = Snapshot(x: x)
            self.snapshot = snapshot
        }
        
        mutating func reset() {
            x = 0
            y = 0
            state = .fetchTileNumber(cycleCounter: 0)
        }
    }
}


protocol PixelFetcherDelegate {
    var tileDataArea: UInt16 { get }
    var tileNumberProvider: (UInt16) -> UInt8 { get }
    var vRamDataProvider: (UInt16) -> UInt8 { get }
    
    func pixelFetcherTileNumberFor(fetcherPosition position: PixelFetcher.ScanlineState.Position) -> UInt8
    func pixelFetcherTileDataFor(tileDataAddress: UInt16) -> [PixelData]
    func pixelFetcherTileDataOffset() -> UInt16
}

//extension PixelFetcherDelegate {
//    func pixelFetcherTileDataFor(tileDataAddress: UInt16) -> [PixelData] {
//        let tileAddress = tileDataAddress + pixelFetcherTileDataOffset()
//        let tileDataLow = vRamDataProvider(tileAddress - 0x8000)
//        let tileDataHigh = vRamDataProvider(tileAddress + 1 - 0x8000)
//        
//        var pixels: [UInt8] = []
//        for i in 0..<8 {
//            pixels.append((tileDataHigh.bit(7 - i).toUInt8() << 1) | tileDataLow.bit(7 - i).toUInt8())
//        }
//        return pixels
//    }
//}

struct BackgroundPixelFetcherDelegate: PixelFetcherDelegate {
    let scx: UInt8
    let scy: UInt8
    let lcdY: UInt8
    let tileMapArea: UInt16
    let tileDataArea: UInt16
    let tileNumberProvider: (UInt16) -> UInt8
    let vRamDataProvider: (UInt16) -> UInt8
    
    func pixelFetcherTileNumberFor(fetcherPosition position: PixelFetcher.ScanlineState.Position) -> UInt8 {
        let position = PixelFetcher.ScanlineState.Position(
            x: UInt16((UInt16(scx) / 8) + position.x) & 0x1F,
            y: (UInt16(lcdY &+ scy) & 0xFF)
        )
        return tileNumberProvider((tileMapArea + position.x + (32 * (position.y / 8)) & 0x3FF) - 0x8000)
    }
    
    func pixelFetcherTileDataOffset() -> UInt16 {
        2 * ((UInt16(lcdY) &+ UInt16(scy)) % 8)
    }
    
    func pixelFetcherTileDataFor(tileDataAddress: UInt16) -> [PixelData] {
        let tileAddress = tileDataAddress + pixelFetcherTileDataOffset()
        let tileDataLow = vRamDataProvider(tileAddress - 0x8000)
        let tileDataHigh = vRamDataProvider(tileAddress + 1 - 0x8000)
        
        var pixels: [PixelData] = []
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
    }
}

struct WindowPixelFetcherDelegate: PixelFetcherDelegate {
    let windowInternalXCounter: UInt8
    let windowInternalLineCounter: UInt8
    let tileMapArea: UInt16
    let tileDataArea: UInt16
    let tileNumberProvider: (UInt16) -> UInt8
    let vRamDataProvider: (UInt16) -> UInt8
    
    func pixelFetcherTileNumberFor(fetcherPosition position: PixelFetcher.ScanlineState.Position) -> UInt8 {
        let position = PixelFetcher.ScanlineState.Position(
            x: UInt16(windowInternalXCounter),
            y: UInt16(windowInternalLineCounter)
        )
        return tileNumberProvider((tileMapArea + position.x + (32 * (position.y / 8)) & 0x3FF) - 0x8000)
    }
    
    func pixelFetcherTileDataOffset() -> UInt16 {
        2 * (UInt16(windowInternalLineCounter) % 8)
    }
    
    func pixelFetcherTileDataFor(tileDataAddress: UInt16) -> [PixelData] {
        let tileAddress = tileDataAddress + pixelFetcherTileDataOffset()
        let tileDataLow = vRamDataProvider(tileAddress - 0x8000)
        let tileDataHigh = vRamDataProvider(tileAddress + 1 - 0x8000)
        
        var pixels: [PixelData] = []
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
    }
}

struct SpritePixelFetcherDelegate: PixelFetcherDelegate {
    let lcdY: UInt8
    let sprite: PPU.Sprite
    let tileDataArea: UInt16
    let tileNumberProvider: (UInt16) -> UInt8
    let vRamDataProvider: (UInt16) -> UInt8
    
    func pixelFetcherTileNumberFor(fetcherPosition position: PixelFetcher.ScanlineState.Position) -> UInt8 {
        if sprite.spriteHeight == 16 {
            let line = UInt16(lcdY + 16 - sprite.position.y)
            if line > 7 {
                if sprite.attribute.yFlip {
                    return sprite.tileNumber & 0xFE
                } else {
                    return sprite.tileNumber | 0x1
                }
            } else {
                if sprite.attribute.yFlip {
                    return sprite.tileNumber | 0x1
                } else {
                    return sprite.tileNumber & 0xFE
                }
            }
        }
        return sprite.tileNumber
    }
    
    func pixelFetcherTileDataOffset() -> UInt16 {
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
    
    func pixelFetcherTileDataFor(tileDataAddress: UInt16) -> [PixelData] {
        let tileAddress = tileDataAddress + pixelFetcherTileDataOffset()
        let tileDataLow = vRamDataProvider(tileAddress - 0x8000)
        let tileDataHigh = vRamDataProvider(tileAddress + 1 - 0x8000)
        
        var pixels: [PixelData] = []
        for i in 0..<8 {
            let color = (tileDataHigh.bit(7 - i).toUInt8() << 1) | tileDataLow.bit(7 - i).toUInt8()
            let pixel = PixelData(
                color: color,
                palette: 0,
                spritePrioriy: 0,
                backgroundPriority: sprite.attribute.priority.rawValue)
            pixels.append(pixel)
        }
        if sprite.attribute.xFlip {
            return pixels.reversed()
        }
        return pixels
    }
}
