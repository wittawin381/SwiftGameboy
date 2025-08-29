//
//  PixelFetcher+Sprite.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 29/8/2568 BE.
//

import Foundation

struct SpritePixelFetcherStrategy: PixelFetcherStrategy {
    let lcdY: UInt8
    let sprite: PPU.Sprite
    let tileDataArea: UInt16
    
    func pixelFetcherTileNumberFor(
        fetcherPosition position: PixelFetcher.ScanlineState.Position,
        from vram: borrowing [UInt8]
    ) -> UInt8 {
        if sprite.spriteHeight == 16 {
            let line = UInt16(lcdY + 16 - sprite.position.y)
            let isSecondHalf: Bool = (line > 7)
            
            /// top tile number is first 7 bit only and bottom tile number is first 7 bit + 1
            return sprite.tileNumber & 0b1111_1110 | (sprite.attribute.yFlip == isSecondHalf ? 0 : 1)
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
    
    func pixelFetcherTileDataFor(
        tileDataAddress: UInt16,
        from vram: borrowing [UInt8]
    ) -> [PixelData] {
        let tileAddress = tileDataAddress + pixelFetcherTileDataOffset()
        let tileDataLow = vram[tileAddress - 0x8000]
        let tileDataHigh = vram[tileAddress + 1 - 0x8000]
        
        var pixels: [PixelData] = []
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
