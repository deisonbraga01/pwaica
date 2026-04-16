import Capacitor
import UIKit
import WebKit

class MainViewController: CAPBridgeViewController, WKNavigationDelegate {
    private let allowedHosts = [
        "icamedtec.com.br",
        "telemedicina.icamedtec.com.br"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        bridge?.webView?.navigationDelegate = self
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if shouldOpenExternally(url: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        loadOfflineFallbackIfNeeded(webView: webView, error: error)
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        loadOfflineFallbackIfNeeded(webView: webView, error: error)
    }

    private func shouldOpenExternally(url: URL) -> Bool {
        guard let host = url.host else {
            return false
        }

        if allowedHosts.contains(where: { host == $0 || host.hasSuffix(".\($0)") }) {
            return false
        }

        return ["http", "https"].contains(url.scheme?.lowercased() ?? "")
    }

    private func loadOfflineFallbackIfNeeded(webView: WKWebView, error: Error) {
        let nsError = error as NSError

        if nsError.code == NSURLErrorCancelled {
            return
        }

        if webView.url?.lastPathComponent == "offline-ios.html" {
            return
        }

        guard let offlineUrl = Bundle.main.url(
            forResource: "offline-ios",
            withExtension: "html",
            subdirectory: "public"
        ) else {
            return
        }

        webView.loadFileURL(
            offlineUrl,
            allowingReadAccessTo: offlineUrl.deletingLastPathComponent()
        )
    }
}
