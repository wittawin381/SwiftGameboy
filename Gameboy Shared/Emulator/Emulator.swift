//
//  Emulator.swift
//  Gameboy iOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Foundation

struct Emulator {
    enum Error: Swift.Error {
        case fileNotFound(name: String)
        case fileDecodingFailed(name: String, Swift.Error)
    }
    
    func loadRom(_ name: String) throws -> Cartridge {
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: nil
        ) else {
            throw Error.fileNotFound(name: name)
        }
        
        do {
            let data = try Data(contentsOf: url)
            var bytes: [UInt8] = []
            let _ = data.withUnsafeBytes { bufferPointer in
                bytes.append(contentsOf: bufferPointer)
            }
            return try Cartridge(data: bytes)
        } catch {
            throw Error.fileDecodingFailed(name: name, error)
        }
    }
    
    func loadBootRom(_ name: String) throws -> [UInt8] {
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: nil
        ) else {
            throw Error.fileNotFound(name: name)
        }
        
        do {
            let data = try Data(contentsOf: url)
            var bytes: [UInt8] = []
            let _ = data.withUnsafeBytes { bufferPointer in
                bytes.append(contentsOf: bufferPointer)
            }
            return bytes
        } catch {
            throw Error.fileDecodingFailed(name: name, error)
        }
    }
}


