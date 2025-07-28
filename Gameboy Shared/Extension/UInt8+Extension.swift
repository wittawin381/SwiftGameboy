//
//  UInt8+Extension.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 6/7/2568 BE.
//

import Foundation

extension UInt8 {
    func updatedBit(at index: UInt8, to value: UInt8) -> UInt8 {
        /// if bit is equal to value we want to set just return the value
        guard !checkBit(at: index, equalTo: value) else { return self }
        /// if bit is set and the value is unset
        if bit(index) {
            return self - (0x1 << index)
        } else { /// if bit is unset and value is set
            return self + (0x1 << index)
        }
    }
    
    mutating func setBit(at index: UInt8, to value: UInt8) {
        /// if bit is equal to value we want to set just return the value
        guard !checkBit(at: index, equalTo: value) else { return }
        /// if bit is set and the value is unset
        if bit(index) {
            self -= (0x1 << index)
        } else { /// if bit is unset and value is set
            self += (0x1 << index)
        }
    }
}
