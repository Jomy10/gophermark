import Metal
import MetalKit

let WIDTH : CGFloat = 1280
let HEIGHT: CGFloat = 720

/// Init the metal view
func getView() throws -> MTKView {
    // Get system default GPU device (can be modified to select another GPU)
    guard let device = MTLCreateSystemDefaultDevice() else {
        fatalError("Failed to get the system's default Metal device")
    }

    let frame = CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT)
    let view = MTKView(frame: frame, device: device)
    view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)

    let allocator = MTKMeshBufferAllocator(device: device)
    let mdlMesh = MDLMesh(sphereWithExtent: [0.75, 0.75, 0.75], segments: [100, 100], inwardNormals: false, geometryType: .triangles, allocator: allocator)
    let mesh = try MTKMesh(mesh: mdlMesh, device: device)

    guard let commandQueue = device.makeCommandQueue() else {
        fatalError("Couldn't create a command queue")
    }

    // Set up metal library
    // let mtlLibFile = NSLocalizedString("shader", bundle: .main, comment: "Shader library") <- not working
    let mtlLibFile = try String(contentsOf: URL(fileURLWithPath: "Sources/gophermark/shader.metal"))
    let library = try device.makeLibrary(source: mtlLibFile, options: nil)
    let vertexFunction = library.makeFunction(name: "vertex_main")
    let fragmentFunction = library.makeFunction(name: "fragment_main")

    // render pipeline
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction

    pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

    let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

    guard let commandBuffer = commandQueue.makeCommandBuffer(), 
        let renderPassDescriptor = view.currentRenderPassDescriptor,
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else { fatalError("Failed to create metal objects") }

    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

    guard let submesh = mesh.submeshes.first else {
        fatalError()
    }

    //////// TODO: to other func ///////
    // Draw (send  command to encoder)
    renderEncoder.drawIndexedPrimitives(
        type: .triangle,
        indexCount: submesh.indexCount,
        indexType: submesh.indexType,
        indexBuffer: submesh.indexBuffer.buffer,
        indexBufferOffset: 0
    )

    // Finish sending commands
    renderEncoder.endEncoding()
    let drawable = view.currentDrawable!
    commandBuffer.present(drawable)
    commandBuffer.commit()

    return view
}

/// Draw tests
