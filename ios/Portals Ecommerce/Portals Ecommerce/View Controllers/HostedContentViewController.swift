import UIKit
import Capacitor

class HostedContentViewController: CAPBridgeViewController, ApplicationCoordinationParticipant {
    weak var coordinator: ApplicationCoordinator?
    
    private(set) var isObservingWebLoading: Bool = false
    private var apiPlugin: ShopAPIPlugin?

    override func viewDidLoad() {
        // register for KVO
        observeWebView()
        // now call super which will start the initial load
        super.viewDidLoad()
        // find the plugin the bridge has instantiated and store a reference to it
        apiPlugin = bridge?.plugin(withName: "ShopAPI") as? ShopAPIPlugin
    }
    
    func webViewCompletedInitialLoad() {
    }
    
    // MARK: - KVO
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let _ = object as? WKWebView else {
            return
        }
        guard let keyPath = keyPath, keyPath == #keyPath(WKWebView.isLoading) else {
            return
        }
        guard let change = change,
              let newValue = change[NSKeyValueChangeKey.newKey] as? Bool,
              let oldValue = change[NSKeyValueChangeKey.oldKey] as? Bool,
              oldValue && !newValue else {
            return
        }
        // initial load is complete, remove observation
        unobserveWebView()
        webViewCompletedInitialLoad()
    }
    
    // MARK: - Internal
    
    // registers as a KVO observer of the web view's loading state
    private func observeWebView() {
        if let webview = webView, !isObservingWebLoading {
            webview.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: [.new, .old], context: nil)
            isObservingWebLoading = true
        }
    }
    
    // unregisters from KVO notifications of the webview's loading state
    private func unobserveWebView() {
        if isObservingWebLoading {
            webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
            isObservingWebLoading = false
        }
    }

}
