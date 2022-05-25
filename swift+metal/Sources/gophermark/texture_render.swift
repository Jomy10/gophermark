import MetalKit

func setupMTLDevice() -> MTLDevice {
    guard let device = MTLCreateSystemDefaultDevice() else {
        fatalError("Failed to get the system's default Metal device")
    }
    return device
}

func setupView(device: MTLDevice) -> MTKView {
    let frame = CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT)
    let view = MTKView(frame: frame, device: device)
    view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
    return view
}

class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var queue: MTLCommandQueue

    init(device: MTLDevice) {
        self.device = device

        // Command queue
        guard let queue = device.makeCommandQueue() else { fatalError("Couldn't create command queue") }
        self.queue = queue
    }

    /// View calls this when the size of the contents change
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    /// Called on the delegate when it is asked to render into the view
    /// Implement drawing process here
    func draw(in view: MTKView) {
        // 1. Create render pass
        guard let commandBuffer = queue.makeCommandBuffer() else { fatalError("Couldn't create command buffer") }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { fatalError("Couldn't create render pass descriptor") }
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { fatalError("couldn't create command encoder") }

        // 2. End a render pass
        commandEncoder.endEncoding()
        // 3. Present a drawable to the screen
        commandBuffer.present(view.currentDrawable!)
        // 4. Commit the command buffer
        commandBuffer.commit()
    }
}
