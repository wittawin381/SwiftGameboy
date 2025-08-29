//
//  PixelFetcher+Strategy.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 29/8/2568 BE.
//

import Foundation

protocol PixelFetcherStrategy {
    var tileDataArea: UInt16 { get }
    
    func pixelFetcherTileNumberFor(fetcherPosition position: PixelFetcher.ScanlineState.Position, from vram: borrowing [UInt8]) -> UInt8
    func pixelFetcherTileDataFor(tileDataAddress: UInt16, from vram: borrowing [UInt8]) -> [PixelData]
    func pixelFetcherTileDataOffset() -> UInt16
}






