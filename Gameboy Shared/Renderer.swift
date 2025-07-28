//
//  Renderer.swift
//  Gameboy Shared
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

// The 256 byte aligned size of our uniform structure
let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 0xFF) & -0x100

let maxBuffersInFlight = 3

enum RendererError: Error {
    case badVertexDescriptor
}

struct FrameBuffer {
    let pixels: UnsafeMutablePointer<UInt8>
    
    init() {
        pixels = .allocate(capacity: 160 * 144)
        pixels.update(repeating: 0, count: 160 * 144)
    }
}

class Renderer: NSObject, MTKViewDelegate {
    
    public let device: MTLDevice
    let vertexBuffer: MTLBuffer
    let texture: MTLTexture
    let commandQueue: MTLCommandQueue
    
    var pipelineState: MTLRenderPipelineState
    
    var frameBuffer = FrameBuffer()
    var gameboy: Device
    
    func emulatorRun() {
        while true {
            let pixelData = gameboy.run()
        }
    }
    
    @MainActor
    init?(metalKitView: MTKView, cartridge: Cartridge, bootRom: [UInt8]) {
        self.device = metalKitView.device!
        guard let queue = self.device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
        
        let library = if let defaultLibrary = device.makeDefaultLibrary() {
            defaultLibrary
        } else {
            fatalError("Error when loading library")
        }
        
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = library.makeFunction(name: "vertex_shader")
        pipelineDesc.fragmentFunction = library.makeFunction(name: "fragment_shader")
        pipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
          pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDesc)
        } catch {
          fatalError("Error when initializing Metal: unable to create render pipeline: \(error)")
        }
        
        let data: [Float] = [
          -1.0, -1.0,
           1.0, -1.0, // swiftlint:disable:this collection_alignment
          -1.0, 1.0,
           1.0, 1.0 // swiftlint:disable:this collection_alignment
        ]

        let bufferCount = data.count * MemoryLayout<Float>.size
        if let buffer = device.makeBuffer(bytes: data, length: bufferCount, options: []) {
            self.vertexBuffer = buffer
        } else {
            fatalError("Error when initializing Metal: unable to create vertex buffer.")
        }

        let textureDesc = MTLTextureDescriptor.texture2DDescriptor(
          pixelFormat: .r8Uint,
          width: 160,
          height: 144,
          mipmapped: false
        )

        if let texture = device.makeTexture(descriptor: textureDesc) {
            self.texture = texture
        } else {
            fatalError("Error when initializing Metal: unable to create texture.")
        }
        
        self.gameboy = Device(
            vRamSize: 1024 * 8,
            internalRamSize: 1024 * 32,
            cartridge: cartridge,
            bootRom: bootRom
        )
        
        super.init()
    }
    
    private func makeLibrary(device: MTLDevice) -> MTLLibrary {
        if let defaultLibrary = device.makeDefaultLibrary() {
            return defaultLibrary
        } else {
            fatalError("Error when loading library")
        }
    }
    
    func draw(in view: MTKView) {
        /// Per frame updates hare
        
        //TODO: wait = gameboy clock
//        _ = inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            
//            let semaphore = inFlightSemaphore
//            commandBuffer.addCompletedHandler { (_ commandBuffer)-> Swift.Void in
//                semaphore.signal()
//            }
            
            print(Date.now.timeIntervalSince1970)
            
            
            let region = MTLRegionMake2D(0, 0, 160, 144)
            texture.replace(region: region,
                            mipmapLevel: 0,
                            withBytes: frameBuffer.pixels,
                            bytesPerRow: 160 * MemoryLayout<UInt8>.size)
            
            /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
            ///   holding onto the drawable and blocking the display pipeline any longer than necessary
            let renderPassDescriptor = view.currentRenderPassDescriptor
            
            if let renderPassDescriptor = renderPassDescriptor, let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                renderEncoder.setRenderPipelineState(self.pipelineState)
                renderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
                renderEncoder.setFragmentTexture(texture, index: 0)
                renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
                
                renderEncoder.endEncoding()
                
                if let drawable = view.currentDrawable {
                    commandBuffer.present(drawable)
                }
            }
            
            commandBuffer.commit()
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
        
        let aspect = Float(size.width) / Float(size.height)
//        projectionMatrix = matrix_perspective_right_hand(fovyRadians: radians_from_degrees(65), aspectRatio:aspect, nearZ: 0.1, farZ: 100.0)
    }
}

// Generic matrix math utility functions
func matrix4x4_rotation(radians: Float, axis: SIMD3<Float>) -> matrix_float4x4 {
    let unitAxis = normalize(axis)
    let ct = cosf(radians)
    let st = sinf(radians)
    let ci = 1 - ct
    let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
    return matrix_float4x4.init(columns:(vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                                         vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                                         vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                                         vector_float4(                  0,                   0,                   0, 1)))
}

func matrix4x4_translation(_ translationX: Float, _ translationY: Float, _ translationZ: Float) -> matrix_float4x4 {
    return matrix_float4x4.init(columns:(vector_float4(1, 0, 0, 0),
                                         vector_float4(0, 1, 0, 0),
                                         vector_float4(0, 0, 1, 0),
                                         vector_float4(translationX, translationY, translationZ, 1)))
}

func matrix_perspective_right_hand(fovyRadians fovy: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
    let ys = 1 / tanf(fovy * 0.5)
    let xs = ys / aspectRatio
    let zs = farZ / (nearZ - farZ)
    return matrix_float4x4.init(columns:(vector_float4(xs,  0, 0,   0),
                                         vector_float4( 0, ys, 0,   0),
                                         vector_float4( 0,  0, zs, -1),
                                         vector_float4( 0,  0, zs * nearZ, 0)))
}

func radians_from_degrees(_ degrees: Float) -> Float {
    return (degrees / 180) * .pi
}
