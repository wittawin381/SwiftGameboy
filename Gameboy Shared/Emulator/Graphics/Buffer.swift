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
    let maxSize: Int
    
    var count: Int {
        get { _size }
    }
    
    var isEmpty: Bool {
        _size == 0
    }
    
    var first: Element? {
        if _size == 0 { return nil }
        else { return buffer[headIndex] }
    }
    
    init(maxSize: Int) {
        self.buffer = UnsafeMutableBufferPointer<Element>.allocate(capacity: maxSize)
        self.headIndex = 0
        self.tailIndex = 0
        self._size = 0
        self.maxSize = maxSize
    }
    
    mutating func enqueue(_ element: Element) {
        var next = tailIndex + 1;
        if next > maxSize - 1 {
            next = 0
        }
        
        buffer[tailIndex] = element
        tailIndex = next
        _size += 1
    }
    
    mutating func dequeue() -> Element {
        var next = headIndex + 1;
        if next > maxSize - 1 {
            next = 0
        }
        let element = buffer[headIndex]
        headIndex = next
        _size -= 1
        return element
    }
    
    mutating func append(contentsOf newElements: [Element]) {
        for i in 0..<newElements.count {
            enqueue(newElements[i])
        }
    }
    
    mutating func removeAll() {
        _size = 0
        headIndex = 0
        tailIndex = 0
    }
    
    mutating func removeFirst(_ n: Int) {
        headIndex += n
        if headIndex > maxSize - 1 {
            headIndex -= maxSize
        }
        _size -= n
    }
    
    subscript(index: Int) -> Element {
        get {
            var retrieveIndex = headIndex + index
            if retrieveIndex > maxSize - 1 {
                retrieveIndex -= maxSize
            }
            return buffer[retrieveIndex]
        }
        set {
            var insertIndex = headIndex + index
            if insertIndex > maxSize - 1 {
                insertIndex -= maxSize
            }
            buffer[insertIndex] = newValue
        }
    }
}
