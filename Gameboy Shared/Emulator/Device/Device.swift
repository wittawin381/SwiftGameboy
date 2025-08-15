//
//  Device.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation

struct Device {
    var cpu: CPU
    var ioRegisters: IORegisters
    var cartridge: Cartridge
    var vRam: [UInt8]
    var internalRam: [UInt8]
    var hRam: [UInt8]
    var objectAttributeMemory: [UInt8]
    
    var bootRom: [UInt8]
    
    init(vRamSize: Int,
         internalRamSize: Int,
         cartridge: Cartridge,
         bootRom: [UInt8]
    ) {
        self.cartridge = cartridge
        self.vRam = Array(repeating: 0, count: vRamSize)
        self.hRam = Array(repeating: 0, count: 127)
        self.internalRam = Array(repeating: 0, count: internalRamSize)
        self.objectAttributeMemory = Array(repeating: 0, count: 160)
        self.cpu = CPU()
        self.ioRegisters = IORegisters()
        self.bootRom = bootRom
    }
    
    mutating func run() -> PPU.AdvanceAction {
        withUnsafeMutablePointer(to: &cpu) { cpu in
            cpu.pointee.advance { address in
                switch address {
                case 0x0...0x7FFF:
                    if ioRegisters.bootSuccess {
                        return cartridge.readValue(at: address)
                    } else {
                        switch address {
                        case 0x0...0xFF:
                            return bootRom[address]
                        case 0x100...0x7FFF:
                            return cartridge.readValue(at: address)
                        default: return 0xFF
                        }
                    }
                case 0x8000...0x9FFF:
                    return vRam[address, offset: 0x8000]
                case 0xA000...0xBFFF:
                    return cartridge.readValue(at: address)
                case 0xC000...0xDFFF:
                    return internalRam[address, offset: 0xC000]
                case 0xFE00...0xFE9F:
                    return objectAttributeMemory[address, offset: 0xFE00]
                case 0xFF00...0xFF7F:
                    return ioRegisters.readValue(at: address)
                case 0xFF80...0xFFFE:
                    return hRam[address, offset: 0xFF80]
                case 0xFFFF:
                    return cpu.pointee.interruptEnable.value
                default: return 0xFF
                }
                
            }
            writeMemory: { value, address in
                if address == 0xC06A, value != 0xCB {
                    print("WRITE HERER")
                }
                /// step 1
                /// 24 c5ad
               /// SET HL : 218 195
               /// SET AF : 198
               /// e0 c5ae
                switch address {
                case 0x0...0x7FFF:
                    return cartridge.memoryBankController.write(value, at: address)
                case 0x8000...0x9FFF:
                    return vRam[address, offset: 0x8000] = value
                case 0xA000...0xBFFF:
                    return cartridge.memoryBankController.write(value, at: address)
                case 0xC000...0xDFFF:
                    return internalRam[address, offset: 0xC000] = value
                case 0xFE00...0xFE9F:
                    return objectAttributeMemory[address, offset: 0xFE00] = value
                case 0xFF00...0xFF7F:
                    return ioRegisters.write(value, at: address)
                case 0xFF80...0xFFFE:
                    return hRam[address, offset: 0xFF80] = value
                case 0xFFFF:
                    return cpu.pointee.interruptEnable.value = value
                default: break
                }
            }
        }
        
        ioRegisters.advance()

        return ioRegisters.ppu.advance(
            vRam: vRam,
            interruptRequestHandler: { type in
                switch type {
                case .stat:
                    ioRegisters.interruptsFlag.set(.lcd)
                case .vBlank:
                    ioRegisters.interruptsFlag.set(.vBlank)
                }
            })
    }
}

extension Device {
    mutating func keyEvent(_ event: KeyEvent) {
        switch event {
        case let .keyUp(joypadKey):
            switch joypadKey {
            case .UP:
                ioRegisters.joypadState.up = true
            case .DOWN:
                ioRegisters.joypadState.down = true
            case .LEFT:
                ioRegisters.joypadState.left = true
            case .RIGHT:
                ioRegisters.joypadState.right = true
            case .A:
                ioRegisters.joypadState.a = true
            case .B:
                ioRegisters.joypadState.b = true
            case .START:
                ioRegisters.joypadState.start = true
            case .SELECT:
                ioRegisters.joypadState.select = true
            }
        case let .keyDown(joypadKey):
            switch joypadKey {
            case .UP:
                ioRegisters.joypadState.up = false
            case .DOWN:
                ioRegisters.joypadState.down = false
            case .LEFT:
                ioRegisters.joypadState.left = false
            case .RIGHT:
                ioRegisters.joypadState.right = false
            case .A:
                ioRegisters.joypadState.a = false
            case .B:
                ioRegisters.joypadState.b = false
            case .START:
                ioRegisters.joypadState.start = false
            case .SELECT:
                ioRegisters.joypadState.select = false
            }
        }
    }
}

enum KeyEvent {
    case keyUp(JoypadKey)
    case keyDown(JoypadKey)
}

enum JoypadKey {
    case UP
    case DOWN
    case LEFT
    case RIGHT
    case A
    case B
    case START
    case SELECT
}


protocol GBJoypadKeyRepresentable {
    var joypadKey: JoypadKey { get }
}
