import Foundation
import UIKit
import WebKit

public protocol EngineWebDelegate: AnyObject {
    func bootstrapped()
    func tap(action: String, system: Bool)
    func routeChanged(newRoute: String)
    func routeError(route: String)
    func routeLoaded(route: String)
    func sizeChanged(width: CGFloat, height: CGFloat)
    func error()
}

public class EngineWeb: NSObject {
    private var _currentRoute = ""

    weak public var delegate: EngineWebDelegate?
    var containerViewController: UIViewController?
    var webView = WKWebView()

    public var view: UIView {
        return webView
    }

    public private(set) var currentRoute: String {
        get {
            return _currentRoute
        }
        set {
            _currentRoute = newValue
        }
    }

    init(configuration: EngineWebConfiguration) {
        super.init()

        containerViewController = UIViewController()
        if let containerViewController = containerViewController {
            containerViewController.view.addSubview(webView)

            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.navigationDelegate = self
            webView.isOpaque = false
            webView.backgroundColor = UIColor.clear
            webView.scrollView.backgroundColor = UIColor.clear

            let contentController = self.webView.configuration.userContentController
            contentController.add(self, name: "gist")

            [webView.topAnchor.constraint(equalTo: containerViewController.view.topAnchor),
             webView.bottomAnchor.constraint(equalTo: containerViewController.view.bottomAnchor),
             webView.leftAnchor.constraint(equalTo: containerViewController.view.leftAnchor),
             webView.rightAnchor.constraint(equalTo: containerViewController.view.rightAnchor)].forEach { anchor in
                anchor.isActive = true
            }

            if #available(iOS 11.0, *) {
                webView.scrollView.contentInsetAdjustmentBehavior = .never
            }

            if let jsonData = try? JSONEncoder().encode(configuration),
               let jsonString = String(data: jsonData, encoding: .utf8),
               let options = jsonString.data(using: .utf8)?.base64EncodedString() {
                let url = "\(Settings.Network.renderer)/index.html?options=\(options)"
                Logger.instance.info(message: "Loading URL: \(url)")
                if let link = URL(string: url) {
                    let request = URLRequest(url: link)
                    webView.load(request)
                }
            }
        }
    }
}

//swiftlint:disable cyclomatic_complexity
extension EngineWeb: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController,
                                      didReceive message: WKScriptMessage) {

        guard let dict = message.body as? [String: AnyObject],
              let eventProperties = dict["gist"] as? [String: AnyObject],
              let method = eventProperties["method"] as? String,
              let engineEventMethod = EngineEvent(rawValue: method) else {
            return
        }

        switch engineEventMethod {
        case .bootstrapped:
            delegate?.bootstrapped()
        case .routeLoaded:
            if let route = EngineEventHandler.getRouteLoadedProperties(properties: eventProperties) {
                delegate?.routeLoaded(route: route)
            }
        case .routeChanged:
            if let route = EngineEventHandler.getRouteChangedProperties(properties: eventProperties) {
                delegate?.routeChanged(newRoute: route)
            }
        case .routeError:
            if let route = EngineEventHandler.getRouteErrorProperties(properties: eventProperties) {
                delegate?.routeError(route: route)
            }
        case .sizeChanged:
            if let size = EngineEventHandler.getSizeProperties(properties: eventProperties) {
                webView.frame.size = CGSize(width: size.width, height: size.height)
                webView.layoutIfNeeded()
                delegate?.sizeChanged(width: size.width, height: size.height)
            }
        case .tap:
            if let tapProperties = EngineEventHandler.getTapProperties(properties: eventProperties) {
                delegate?.tap(action: tapProperties.action, system: tapProperties.system)
            }
        case .error:
            delegate?.error()
        }
    }
}

extension EngineWeb: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(
            "window.parent.postMessage = function(message) {webkit.messageHandlers.gist.postMessage(message)}")
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        delegate?.error()
    }

    public func webView(_ webView: WKWebView,
                        didFail navigation: WKNavigation!,
                        withError error: Error) {
        delegate?.error()
    }

    public func webView(_ webView: WKWebView,
                        didFailProvisionalNavigation navigation: WKNavigation!,
                        withError error: Error) {
        delegate?.error()
    }
}
