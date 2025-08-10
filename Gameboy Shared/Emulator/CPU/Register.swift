//
//  Register.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 28/7/2568 BE.
//

import Foundation

public extension CPU {
    struct Register {
        private var _lo: UInt8
        private var _hi: UInt8
        
        init(_ l: UInt8, _ h: UInt8) {
            self._lo = l
            self._hi = h
        }
        
        init(_ value: UInt16) {
            self._lo = UInt8(value & 0xFF)
            self._hi = UInt8(value >> 8)
        }
        
        public var lo: UInt8 {
            get { _lo }
            set { _lo = newValue }
        }
        
        public var hi: UInt8 {
            get { _hi }
            set { _hi = newValue }
        }
        
        public var all: UInt16 {
            get { (UInt16(_hi) << 8) + UInt16(_lo) }
            set {
                _hi = UInt8(newValue >> 8)
                _lo = UInt8(newValue & 0xFF);
            }
        }
    }
}
