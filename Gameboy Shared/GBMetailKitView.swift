////
////  GBMetailKitView.swift
////  Gameboy
////
////  Created by Wittawin Muangnoi on 8/8/2568 BE.
////
//
//import Foundation
//import MetalKit
//
//class GBMetailKitView: MTKView {
//    var frameBuffer = FrameBuffer()
//    var gameboy: Device
//    
//    init(gameboy: Device) {
//        self.gameboy = gameboy
//        super.init(frame: .zero, device: <#T##(any MTLDevice)?#>)
//    }
//    
//    required init(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func emulatorRun() {
//        var previousTime = CACurrentMediaTime()
//        while true {
////            let currentTime = CACurrentMediaTime()
////            if currentTime  - previousTime >= 0.000250 {
////                previousTime = currentTime
////                let action = gameboy.run()
////                switch action {
////                case .idle:
////                    break
////                case .drawFrame(let frameBuffer):
////                    self.frameBuffer = frameBuffer
////                    let draw = CACurrentMediaTime()
////                }
////            }
//            let action = gameboy.run()
//            switch action {
//            case .idle:
//                break
//            case .drawFrame(let frameBuffer):
//                Task {
//                    self.frameBuffer = frameBuffer
//                }
////                let draw = CACurrentMediaTime()
//            }
//        }
//    }
//}
