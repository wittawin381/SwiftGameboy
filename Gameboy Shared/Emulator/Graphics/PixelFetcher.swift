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
            case fetchTileNumber
            
            case fetchTileData(
                tileDataArea: UInt16,
                pixelDataFetcher: (UInt16, [UInt8]) -> [PixelData],
                tileNumber: UInt8,
                usingUnsignedAddressing: Bool
            )
            
            case idle(pixels: [PixelData])
        }
        
        enum AdvanceAction {
            case idle
            case incrementXCounter
            case pushPixelRow([PixelData])
        }
        
        mutating func advance(delegate: PixelFetcherStrategy, vram: borrowing [UInt8]) -> AdvanceAction {
            switch state {
            case .fetchTileNumber:
                let tileNumber = delegate.pixelFetcherTileNumberFor(fetcherPosition: Position(x: x, y: y), from: vram)
                
                let usingUnsignedAddressing = delegate.tileDataArea == 0x8000 || delegate.tileDataArea == 0x9000
                
                self.state = .fetchTileData(
                    tileDataArea: delegate.tileDataArea,
                    pixelDataFetcher: delegate.pixelFetcherTileDataFor(tileDataAddress:from:),
                    tileNumber: tileNumber,
                    usingUnsignedAddressing: usingUnsignedAddressing
                )
                return .idle
            case let .fetchTileData(
                tileDataArea,
                pixelDataFetcher,
                tileNumber,
                usingUnsignedAddressing
            ):
                let tileDataAddress: UInt16 = if usingUnsignedAddressing {
                    tileDataArea + (UInt16(tileNumber) * 16)
                } else {
                    tileDataArea + (UInt16((UInt8(bitPattern: Int8(bitPattern: tileNumber)) &+ 128)) * 16)
                }
                
                let pixels = pixelDataFetcher(tileDataAddress, vram)
                
                
                self.state = .idle(pixels: pixels)
                return .incrementXCounter
            case let .idle(pixels):
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

