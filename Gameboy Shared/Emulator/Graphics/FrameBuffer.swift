//
//  FrameBuffer.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 11/8/2568 BE.
//

import Foundation

class Ref<Value> {
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}

struct FrameBuffer {
    var ref: Ref<UnsafeMutablePointer<UInt8>>
    
    init() {
        let pixels = UnsafeMutablePointer<UInt8>.allocate(capacity: 160 * 144)
        pixels.update(repeating: 0, count: 160 * 144)
        ref = Ref(pixels)
    }
    
    var value: UnsafeMutablePointer<UInt8> {
        get { ref.value }
        set {
            if !isKnownUniquelyReferenced(&ref) {
                ref = Ref(newValue)
            }
            ref.value = newValue
        }
    }
}
