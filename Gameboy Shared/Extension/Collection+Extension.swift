//
//  Collection.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 28/7/2568 BE.
//

import Foundation

extension Array {
    subscript(index: UInt16) -> Self.Element {
        get { self[Int(index)] }
        set { self[Int(index)] = newValue }
    }
    
    subscript(index: UInt16, offset offset: UInt16) -> Self.Element {
        get { self[Int(index) - Int(offset)] }
        set { self[Int(index) - Int(offset)] = newValue }
    }
}
