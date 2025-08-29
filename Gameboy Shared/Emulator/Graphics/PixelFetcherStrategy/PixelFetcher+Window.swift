//
//  PixelFetcher+Window.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 29/8/2568 BE.
//

import Foundation

struct WindowPixelFetcherStrategy: PixelFetcherStrategy {
    let windowInternalXCounter: UInt8
    let windowInternalLineCounter: UInt8
    let tileMapArea: UInt16
    let tileDataArea: UInt16
    
    func pixelFetcherTileNumberFor(
        fetcherPosition position: PixelFetcher.ScanlineState.Position,
        from vram: borrowing [UInt8]
    ) -> UInt8 {
        let position = PixelFetcher.ScanlineState.Position(
            x: UInt16(windowInternalXCounter),
            y: UInt16(windowInternalLineCounter)
        )
        return vram[(tileMapArea + position.x + (32 * (position.y / 8)) & 0x3FF) - 0x8000]
    }
    
    func pixelFetcherTileDataOffset() -> UInt16 {
        2 * (UInt16(windowInternalLineCounter) % 8)
    }
    
    func pixelFetcherTileDataFor(
        tileDataAddress: UInt16,
        from vram: borrowing [UInt8]
    ) -> [PixelData] {
        let tileAddress = tileDataAddress + pixelFetcherTileDataOffset()
        let tileDataLow = vram[tileAddress - 0x8000]
        let tileDataHigh = vram[tileAddress + 1 - 0x8000]
        
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
