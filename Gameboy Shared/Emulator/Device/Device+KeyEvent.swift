//
//  Device+KeyEvent.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 18/8/2568 BE.
//

import Foundation

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
