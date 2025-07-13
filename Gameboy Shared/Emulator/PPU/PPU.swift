//
//  PPU.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 12/7/2568 BE.
//

import Foundation

struct PPU {
    var lcdControl: LCDControl
    /// LCD Y coordinate means y position or current line which is about to be drawn
    /// value from 0 - 155 -> 0 - 144 for normal line > 144 - 153 means VBlank period
    /// 0xFF44
    var lcdY: UInt8 = 0
    /// if lcdYCompare = lcdY flag in state register is set
    /// 0xFF45
    var lcdYCompare: UInt8 = 0
    // TODO: implement LCD Status and interrupt
    /// 0xFF41
    var lcdStatus: UInt8 = 0
    
    /// 0xFF42 background Y off set withint background map
    var scy: UInt8 = 0
    /// 0xFF43 background X off set withint background map
    var scx: UInt8 = 0
    
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
    
    func render(vRam: [UInt8]) -> PixelRenderer {
        
    }
    
    private func getTile(vRam: [UInt8]) -> {
        if lcdControl.backgroundTileMapArea == 1 {
            
        }
    }
}

struct PixelFetcher {
    
}

struct LCDControl {
    /// Bit 7 - set display enable
    var lcdDisplayEnabled: Bool = false
    /// Bit 6 - window tile map area 0 = 9800 - 9BFF, 1 = 9C00 – 9FFF
    var windowTileMapArea: Int = 0
    /// Bit 5 - set this to false hide window layer entirely
    var windowEnabled: Bool = false
    /// Bit 4 - tile data are 0 = 8800 – 97FF, 1 = 8000 – 8FFF
    var tileDataArea: Int = 0
    /// Bit 3 - background tile map area 0 = 9800 – 9BFF, 1 = 9C00 – 9FFF
    var backgroundTileMapArea: Int = 0
    /// Bit 2 - sprite size 0 = 8x8 1 = 8x16
    var spriteSize: Int = 0
    /// Bit 1 - if 0 sprite is not drawn on screen
    var spriteEnabled: Bool = false
    /// Bit 0 - if false background and window layer are not drawn
    var backgroundAndWindowEnalbed: Bool = false
}
