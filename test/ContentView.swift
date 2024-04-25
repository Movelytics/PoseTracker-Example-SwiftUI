import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL
    @ObservedObject var viewModel: ViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        // Configuration du contrôleur de contenu pour gérer les messages de JavaScript
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "iosListener")
        webConfiguration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject, WKScriptMessageHandler {
        var viewModel: ViewModel

        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let data = message.body as? String {
                DispatchQueue.main.async {
                    self.viewModel.updateData(with: data)
                }
            }
        }
    }
}

class ViewModel: ObservableObject {
    @Published var info: String = "Waiting for data..."

    func updateData(with data: String) {
        self.info = data
    }
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            Text(viewModel.info)
                .padding()
            WebView(url: URL(string: "https://www.posetracker.com/pose_tracker/tracking?token=494e020b-7cc8-4aed-815b-4674d10d4f30&exercise=squat&difficulty=easy&width=350&height=350&progression=true")!, viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
