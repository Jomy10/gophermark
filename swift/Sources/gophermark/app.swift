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
    var body: some View {
        MetalView()
            .frame(width: WIDTH, height: HEIGHT)
    }
}

/// SwiftUI Wrapper for the metal view
struct MetalView: NSViewRepresentable {
    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
        guard let view = try? getView() else {
            fatalError()
        }

        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {

    }

}

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		NSApplication.shared.setActivationPolicy(.regular)
		NSApplication.shared.activate(ignoringOtherApps: true)
	}

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
}
