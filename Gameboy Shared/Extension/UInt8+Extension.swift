//
//  UInt8+Extension.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 6/7/2568 BE.
//

import Foundation

extension UInt8 {
//    mutating func setBit(at index: UInt8, to value: UInt8) {
//        /// if bit is equal to value we want to set just return the value
//        guard !checkBit(at: index, equalTo: value) else { return }
//        /// if bit is set and the value is unset
//        if bit(index) {
//            self -= (0x1 << index)
//        } else { /// if bit is unset and value is set
//            self += (0x1 << index)
//        }
//    }
    mutating func setBit(at index: UInt8) {
        self |= (0x1 << index)
    }
    
    mutating func unsetBit(at index: UInt8) {
        self &= ~(0x1 << index)
    }
    
    func withBitSet(at index: UInt8) -> UInt8 {
        return self | (0x1 << index)
    }
    
    func withBitUnset(at index: UInt8) -> UInt8 {
        return self & ~(0x1 << index)
    }
}
