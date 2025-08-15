//
//  UInt8+Extension.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 6/7/2568 BE.
//

import Foundation

protocol BitAccessible {
    func bit(_ index: UInt8) -> Bool
}

extension BitAccessible where Self: FixedWidthInteger {
    func bit(_ index: UInt8) -> Bool {
        (self >> index) & 0x1 == 1
    }
}

//extension UInt8: BitAccessible {}

public extension UInt8 {
    func bit(_ index: UInt8) -> Bool {
        (self >> index) & 0x1 == 1
    }
    
    func bit(_ index: Int) -> Bool {
        (self >> index) & 0x1 == 1
    }
}

public extension UInt16 {
    func bit(_ index: UInt8) -> Bool {
        (self >> index) & 0x1 == 1
    }
}

//extension UInt16: BitAccessible {}
