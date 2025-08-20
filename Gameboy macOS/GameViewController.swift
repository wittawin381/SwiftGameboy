//
//  GameViewController.swift
//  Gameboy macOS
//
//  Created by Wittawin Muangnoi on 1/7/2568 BE.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {

    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }
//        mtkView.preferredFramesPerSecond = 60

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice

        guard let cartridge = try? Emulator().loadRom("Kirby's Dream Land (USA, Europe).gb") else { return }
        
        guard let bootRom = try? Emulator().loadBootRom("dmg_boot.bin") else { return }

        guard let newRenderer = Renderer(
            metalKitView: mtkView,
            cartridge: cartridge,
            bootRom: bootRom
        ) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.emulatorRun()
        
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
    }
}
