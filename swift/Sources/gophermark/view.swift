import Metal
import MetalKit
import AppKit
import Accelerate

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
        fatalError("couldn't create submesh")
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

    getTexture(device: device)

    // Finish sending commands
    renderEncoder.endEncoding()
    let drawable = view.currentDrawable!
    commandBuffer.present(drawable)
    commandBuffer.commit()

    return view
}

/// Draw tests
func getTexture(device: MTLDevice) {
    // read image 
    // let image = try Data(contentsOf: URL(fileURLWithPath: "../man.png")) 
    guard let nsImage = NSImage(contentsOf: URL(fileURLWithPath: "../man.png")) else { fatalError("couldn't create NSImage") }
    guard let image = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil), 
          let sourceColorSpace = image.colorSpace else { fatalError("Couldn't create CGImage or color space") }
    let width = image.width
    let height = image.height

    let bytesPerPixel = 4
    let bitsPerComponent = 8

    let bytesPerRow = 4 * bytesPerPixel

    // Create region
    let textureDescriptor = MTLTextureDescriptor
        .texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: width, 
            height: height, 
            mipmapped: false)

    // let textureLoader = MTKTextureLoader(device: device)
    // let texture = try textureLoader.newTexture(cgImage: image, options: nil)
    guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
        fatalError("Couldn't create metal texture")
    }

    var format = vImage_CGImageFormat(
        bitsPerComponent: UInt32(image.bitsPerComponent),
        bitsPerPixel: UInt32(image.bitsPerPixel), 
        colorSpace: Unmanaged.passRetained(sourceColorSpace),
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
        version: 0,
        decode: nil,
        renderingIntent: CGColorRenderingIntent.defaultIntent
    )
    var sourceBuffer = vImage_Buffer()

    defer {
        free(sourceBuffer.data)
    }

    var err = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, image, numericCast(kvImageNoFlags))
    
    guard err == kvImageNoError else {
        fatalError("can't vImageBuffer_InitWithCGImage")
    }

    var destCGImage = vImageCreateCGImageFromBuffer(&sourceBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &err)?.takeRetainedValue()

    guard err == kvImageNoError else {
        fatalError("can't vImageCreateCGImageFromBuffer")
    }

    let dstData: CFData = (destCGImage!.dataProvider!.data)!
    let pixelData = CFDataGetBytePtr(dstData)

    destCGImage = nil

    // copy image data into texture
    let region = MTLRegionMake2D(0, 0, width, height)

    texture.replace(region: region, mipmapLevel: 0, withBytes: pixelData!, bytesPerRow: bytesPerRow)
}

