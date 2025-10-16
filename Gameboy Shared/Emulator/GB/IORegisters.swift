//
//  IORegisters.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 16/7/2568 BE.
//

import Foundation

public struct IORegisters {
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
    var lcdY: UInt8 = 0 {
        didSet {
            lcdStatus.lcdYCompareEqual = lcdY == lcdYCompare
        }
    }
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
    
    
    var bootSuccess: Bool = false
    var joypadState: JoypadState = JoypadState()
    var interruptsFlag: InterruptRegister = InterruptRegister(value: 0x0)
    
    var systemCounter = SystemCounter()
    var divider: UInt8 {
        get { UInt8(systemCounter.value >> 8) & 0xFF }
    }
    
    var timerCounter: UInt8 = 0x0
    var timerModulo: UInt8 = 0x0
    var timerControl: TimerControl = .init(value: 0x0)
    var timerCycleCounter: Int = 0x0
    
    var serialTransferData: UInt8 = 0x0
    
    var isInterruptPending: Bool = false
    
    struct TimerControl {
        var value: UInt8 {
            didSet {
                tickAtCycle = switch value & 0b00000011 {
                    case 0: 1024
                    case 1: 16
                    case 2: 64
                    case 3: 256
                    default: 0
                }
                
                isEnable = value.bit(2)
            }
        }
        
        var clockModeBit: UInt8 {
            switch value & 0b00000011 {
                case 0: 9
                case 1: 3
                case 2: 5
                case 3: 7
                default: 0
            }
        }
        
        /// clock rate in T cycle = M cycle * 4
        var tickAtCycle: Int = 0
        
        var isEnable: Bool = false
    }
    
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
    
    enum PPUMode: RawRepresentable {
        case mode0(cycleCounter: Int, initial: Bool = false)
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
    
    mutating func write(_ value: UInt8, at address: UInt16) {
        switch address {
        case 0xFF01:
            serialTransferData = value
        case 0xFF02:
            break
        case 0xFF04:
            systemCounter.value = 0
        case 0xFF05:
            timerCounter = value
            timerCycleCounter = 0
        case 0xFF06:
            timerModulo = value
        case 0xFF07:
            timerControl.value = value
        case 0xFF00:
            joypadState.write(value & 0xF0 | joypadState.value & 0x0F)
        case 0xFF0F:
            interruptsFlag.value = value
        case 0xFF40:
            lcdControl = .init(value)
        case 0xFF41:
            lcdStatus.value = value & 0b0111_1000 | lcdStatus.value & 0b0000_0111
        case 0xFF42:
            scy = value
        case 0xFF43:
            scx = value
        case 0xFF44:
            fatalError("LY is Read Only")
        case 0xFF45:
            lcdYCompare = value
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
        case 0xFF50:
            bootSuccess = value == 1
        default:
            break
        }
    }
    
    func readValue(at address: UInt16) -> UInt8 {
        return switch address {
        case 0xFF00:
            joypadState.read()
        case 0xFF01:
            serialTransferData
        case 0xFF04:
            divider
        case 0xFF05:
            timerCounter
        case 0xFF06:
            timerModulo
        case 0xFF07:
            timerControl.value
        case 0xFF0F:
            interruptsFlag.value
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
        default:
            0xFF
        }
    }
    
    mutating func advance() {
        if isInterruptPending {
            if timerCycleCounter < 4 {
                timerCycleCounter &+= 1
            } else {
                timerCycleCounter = 0
                interruptsFlag.set(.timer)
                isInterruptPending = false
            }
        }
        let isTick = systemCounter.clock(selectedBit: timerControl.clockModeBit)
        
        if timerControl.isEnable {
            timerCycleCounter &+= 1
            if isTick {
                let result = timerCounter.addingReportingOverflow(1)
                if result.overflow {
                    timerCounter = timerModulo
                    isInterruptPending = true
                } else {
                    timerCounter = result.partialValue
                }
            }
        }
    }
}

struct SystemCounter {
    var value: UInt16 = 0x0
    
    private var _selectedBit: UInt8 = 0x0
    
    mutating func clock(selectedBit index: UInt8) -> Bool {
        if value.bit(index) == true, (value &+ 1).bit(index) == false {
            value &+= 1
            return true
        }
        value &+= 1
        return false
    }
}

extension IORegisters {
    struct JoypadState {
        var value: UInt8 = 0xFF
        
        var dPadSelected: Bool {
            value.bit(4) == false
        }
        
        var buttonSelected: Bool {
            value.bit(5) == false
        }
        
        /// inverse since bit = 0 means key pressed
        var up: Bool = true
        var down: Bool = true
        var left: Bool = true
        var right: Bool = true
        
        var a: Bool = true
        var b: Bool = true
        var start: Bool = true
        var select: Bool = true
        
        mutating func write(_ value: UInt8) {
            self.value = value
        }
        
        func read() -> UInt8 {
            if dPadSelected {
                return down.toUInt8() << 3 | up.toUInt8() << 2 | left.toUInt8() << 1 | right.toUInt8()
            } else if buttonSelected {
                return start.toUInt8() << 3 | select.toUInt8() << 2 | b.toUInt8() << 1 | a.toUInt8()
            }
            return 0xF
        }
    }
}

extension IORegisters {
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
            set { value = (value & 0b0111_1100) | (newValue & 0b0000_0011) }
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
            if value {
                self.value.setBit(at: index)
            } else {
                self.value.unsetBit(at: index)
            }
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
