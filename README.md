## TODO :
# 1. Create a new iOS app in xcode
# 2. Use this code
Copy/past this in your ContentView and modify your API_KEY : 
```
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var url: URL
    @ObservedObject var viewModel: ViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
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
            WebView(url: URL(string: "https://www.posetracker.com/pose_tracker/tracking?token=API_KEY&exercise=squat&difficulty=easy&width=350&height=350&progression=true")!, viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
```

# 3. How does it works ?
First we have the webview : 
```
WebView(url: URL(string: "https://www.posetracker.com/pose_tracker/tracking?token=
API_KEY&exercise=squat&difficulty=easy&width=350&height=350&progression=true")!, viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
```
REPLACE the token in url params ="https://...?token=API_KEY" with your own API_KEY

# 4. Important, the webview is using the device webcam so you need to add configuration to the webview
```
let webConfiguration = WKWebViewConfiguration()
webConfiguration.allowsInlineMediaPlayback = true
```

# 5. 🟧 Important point : Data exchange between PoseTracker and your web app 🟧
PoseTracker page will send information with a iosListener.poseMessage so you can handle then this way:
```
let userContentController = WKUserContentController()
userContentController.add(context.coordinator, name: "iosListener")
webConfiguration.userContentController = userContentController

let webView = WKWebView(frame: .zero, configuration: webConfiguration)
webView.load(URLRequest(url: url))
```

# 6. Then you can handle data received : 
```
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
    
    &&
    
class ViewModel: ObservableObject {
    @Published var info: String = "Waiting for data..."

    func updateData(with data: String) {
        self.info = data
    }
}
```


# You can find all the informations returned by PoseTracker here : https://posetracker.gitbook.io/posetracker-api/tracking-endpoint-informations
