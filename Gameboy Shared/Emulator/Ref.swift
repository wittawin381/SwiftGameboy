//
//  Ref.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 13/7/2568 BE.
//

import Foundation

@propertyWrapper struct Ref<Value> {
    class Storage {
        var value: Value
        
        init(_ value: Value) {
            self.value = value
        }
    }
    private var storage: Storage
    
    init(wrappedValue value: Value) {
        self.storage = Storage(value)
    }
    
    var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.value = newValue  }
    }
    
    var projectedValue: RefBinding<Value> {
        RefBinding(
            get: { wrappedValue },
            set: { value in
                wrappedValue = value
            }
        )
    }
}

@propertyWrapper struct RefBinding<Value> {
    var wrappedValue: Value {
        get { get() }
        set { set(newValue) }
    }
    
    private let get: () -> Value
    private let set: (Value) -> Void
    
    init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }
}
