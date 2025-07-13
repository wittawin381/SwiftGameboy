//
//  Instruction+Helper.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 3/7/2568 BE.
//

import Foundation

func checkCarry(_ firstValue: UInt16, _ secondValue: UInt16, atBit bit: Int) -> Bool {
    let maskValue: UInt16 = 0xFF >> (15 - bit)
    return (firstValue & maskValue) + (secondValue & maskValue) > maskValue
}

func createRegisterFValueFromFlag(z: UInt8, n: UInt8, h: UInt8, c: UInt8) -> UInt8 {
    return (z << 7) | (n << 6) | (h << 5) | (c << 4)
}
