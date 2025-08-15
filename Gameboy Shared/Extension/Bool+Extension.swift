//
//  Bool+Extension.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 3/7/2568 BE.
//

import Foundation

public extension Bool {
    func toUInt8() -> UInt8 {
        return self ? 1 : 0
    }
    
    func toUInt16() -> UInt16 {
        return self ? 1 : 0
    }
}
