//
//  FrameBuffer.swift
//  GameboyTests
//
//  Created by Wittawin Muangnoi on 11/8/2568 BE.
//

import Foundation

public struct FrameBuffer {
    private var buffer: UnsafeMutablePointer<UInt8>
    
    init() {
        buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 160 * 144)
        buffer.update(repeating: 0, count:  160 * 144)
    }
    
    var value: UnsafeMutablePointer<UInt8> {
        get { buffer }
        set { buffer = newValue }
    }
}
