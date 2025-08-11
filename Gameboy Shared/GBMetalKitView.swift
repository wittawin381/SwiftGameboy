//
//  GBMetailKitView.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 8/8/2568 BE.
//

import Foundation
import MetalKit
import Carbon.HIToolbox

protocol GBMetailKitViewDelegate: AnyObject {
    func metalKitView(_ metalKitView: GBMetalKitView, keyboardDidPressed key: GBMetalKitView.KeyCode)
    func metalKitView(_ metalKitView: GBMetalKitView, keyboardDidReleased key: GBMetalKitView.KeyCode)
}

class GBMetalKitView: MTKView {
    weak var gbMetalKitViewDelegate: (any GBMetailKitViewDelegate)?
    
    enum KeyCode: GBJoypadKeyRepresentable {
        case w
        case a
        case s
        case d
        case m
        case k
        case enter
        case space
        
        init?(rawValue: Int) {
            switch rawValue {
                case kVK_ANSI_W             : self = .w
                case kVK_ANSI_A             : self = .a
                case kVK_ANSI_S             : self = .s
                case kVK_ANSI_D             : self = .d
                case kVK_ANSI_K             : self = .k
                case kVK_ANSI_M             : self = .m
                case kVK_Return             : self = .enter
                case kVK_Space              : self = .space
            default: return nil
            }
        }
        
        var joypadKey: JoypadKey {
            return switch self {
            case .w     : .UP
            case .a     : .LEFT
            case .s     : .DOWN
            case .d     : .RIGHT
            case .m     : .B
            case .k     : .A
            case .enter : .START
            case .space : .SELECT
            }
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func keyDown(with theEvent: NSEvent) {
        guard let keycode = KeyCode(rawValue: Int(theEvent.keyCode)) else { return }
        gbMetalKitViewDelegate?.metalKitView(self, keyboardDidPressed: keycode)
    }
    
    override func keyUp(with theEvent: NSEvent) {
        guard let keycode = KeyCode(rawValue: Int(theEvent.keyCode)) else { return }
        gbMetalKitViewDelegate?.metalKitView(self, keyboardDidReleased: keycode)
    }
}
