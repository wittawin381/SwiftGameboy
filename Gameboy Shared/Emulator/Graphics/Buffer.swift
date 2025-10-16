//
//  Buffer.swift
//  Gameboy
//
//  Created by Wittawin Muangnoi on 16/10/2568 BE.
//

import Foundation

struct Buffer<Element> {
    private var buffer: UnsafeMutableBufferPointer<Element>
    private var _size: Int = 0
    var headIndex: Int = 0
    var tailIndex: Int = 0
    var size: Int {
        get { _size }
    }
    let maxSize: Int
    
    init(size: Int, maxSize: Int) {
        self.buffer = UnsafeMutableBufferPointer<Element>.allocate(capacity: maxSize)
        self.headIndex = 0
        self.tailIndex = 0
        self._size = 0
        self.maxSize = maxSize
    }
    
    mutating func enqueue(_ element: Element) {
        var next = tailIndex + 1;
        if next > maxSize {
            next = 0
        }
        if next == headIndex {
            fatalError("buffer overflow")
        }
        
        buffer[tailIndex] = element
        tailIndex = next
        _size += 1
    }
    
    mutating func dequeue() -> Element {
        var next = headIndex + 1;
        if next > maxSize {
            next = 0
        }
        let element = buffer[headIndex]
        headIndex = next
        _size -= 1
        return element
    }
    
    subscript(index: Int) -> Element {
        buffer[index]
    }
}
