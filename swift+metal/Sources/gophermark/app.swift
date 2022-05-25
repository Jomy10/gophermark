import SwiftUI
import MetalKit

@main
/// Main app
struct SnakeApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		WindowGroup("Snake") {
			ContentView()
		}
	}
}

/// Main view
struct ContentView: View {
    let image: CGImage

    init() {
        let nsImage = NSImage(contentsOf: URL(fileURLWithPath: "../man.png"))!
        let image = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        self.image = image
    }

    var body: some View {
        MetalView()
        // Image(self.image, scale: 1, label: Text("image"))
            .frame(width: WIDTH, height: HEIGHT)
    }
}

/// SwiftUI Wrapper for the metal view
struct MetalView: NSViewRepresentable {
    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
        let device = setupMTLDevice()
        let view = setupView(device: device)
        view.device = device
        let renderer = Renderer(device: device)
        view.delegate = renderer

        /*
        guard let view = try? getView() else {
            fatalError()
        }
        */

        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}

}

/// Window/app settings
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		NSApplication.shared.setActivationPolicy(.regular)
		NSApplication.shared.activate(ignoringOtherApps: true)
	}

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
}

