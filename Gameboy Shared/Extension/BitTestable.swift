//
//  BitTestable.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 6/7/2568 BE.
//

import Foundation

protocol BitTestable {
    func checkBit(at index: UInt8, equalTo bit: UInt8) -> Bool
}

extension BitTestable where Self: FixedWidthInteger {
    func checkBit(at index: UInt8, equalTo bit: UInt8) -> Bool {
        (self >> index) & 0x1 == bit
    }
}

extension UInt8: BitTestable {}

extension UInt16: BitTestable {}
