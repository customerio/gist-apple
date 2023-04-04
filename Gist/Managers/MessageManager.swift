import Foundation
import UIKit

public enum GistMessageActions: String {
    case close = "gist://close"
}

class MessageManager: EngineWebDelegate {
    private var engine: EngineWeb?
    private let siteId: String
    private var messagePosition: MessagePosition = .top
    private var messageLoaded = false
    private var modalViewManager: ModalViewManager?
    var isMessageEmbed = false
    let currentMessage: Message
    var gistView: GistView!
    private var currentRoute: String
    private var elapsedTimer = ElapsedTimer()
    weak var delegate: GistDelegate?

    init(siteId: String, message: Message) {
        self.siteId = siteId
        self.currentMessage = message
        self.currentRoute = message.messageId

        let engineWebConfiguration = EngineWebConfiguration(
            siteId: self.siteId,
            messageId: message.messageId,
            instanceId: message.instanceId,
            endpoint: Settings.Network.gistAPI,
            properties: message.toEngineRoute().properties)

        engine = EngineWeb(configuration: engineWebConfiguration)
        if let engine = engine {
            engine.delegate = self
            gistView = GistView(message: self.currentMessage, engineView: engine.view)
        }
    }

    func showMessage(position: MessagePosition) {
        elapsedTimer.start(title: "Displaying modal for message: \(currentMessage.messageId)")
        messagePosition = position
    }

    func getMessageView() -> GistView {
        isMessageEmbed = true
        return gistView
    }

    private func loadModalMessage() {
        if messageLoaded {
            modalViewManager = ModalViewManager(gistView: gistView, position: messagePosition)
            modalViewManager?.showModalView { [weak self] in
                guard let self = self else { return }
                self.delegate?.messageShown(message: self.currentMessage)
                self.elapsedTimer.end()
            }
        }
    }

    func dismissMessage(completionHandler: (() -> Void)? = nil) {
        if let modalViewManager = modalViewManager {
            modalViewManager.dismissModalView { [weak self] in
                guard let self = self else { return }
                self.delegate?.messageDismissed(message: self.currentMessage)
                completionHandler?()
            }
        }
    }

    func bootstrapped() {
        Logger.instance.debug(message: "Bourbon Engine bootstrapped")
    }

    func tap(name: String, action: String, system: Bool) {
        Logger.instance.info(message: "Action triggered: \(action) with name: \(name)")
        delegate?.action(message: currentMessage, currentRoute: self.currentRoute, action: action, name: name)
        gistView.delegate?.action(message: currentMessage, currentRoute: self.currentRoute, action: action, name: name)

        if let url = URL(string: action), url.scheme == "gist" {
            switch url.host {
            case "close":
                Logger.instance.info(message: "Dismissing from action: \(action)")
                dismissMessage()
            case "loadPage":
                if let page = url.queryParameters?["url"],
                   let pageUrl = URL(string: page),
                   UIApplication.shared.canOpenURL(pageUrl) {
                    UIApplication.shared.open(pageUrl)
                }
            case "showMessage":
                if currentMessage.isEmbedded {
                    self.showNewMessage(url: url)
                } else {
                    dismissMessage {
                        self.showNewMessage(url: url)
                    }
                }
            default: break
            }
        } else {
            if system {
                if let url = URL(string: action), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url) { handled in
                        if handled {
                            Logger.instance.info(message: "Dismissing from system action: \(action)")
                            self.dismissMessage()
                        } else {
                            Logger.instance.info(message: "System action not handled")
                        }
                    }
                }
            }
        }
    }

    func routeChanged(newRoute: String) {
        Logger.instance.info(message: "Message route changed to: \(newRoute)")
    }

    func sizeChanged(width: CGFloat, height: CGFloat) {
        gistView.delegate?.sizeChanged(message: currentMessage, width: width, height: height)
        Logger.instance.debug(message: "Message size changed Width: \(width) - Height: \(height)")
    }

    func routeError(route: String) {
        Logger.instance.error(message: "Error loading message with route: \(route)")
        delegate?.messageError(message: self.currentMessage)
    }

    func error() {
        Logger.instance.error(message: "Error loading message with id: \(currentMessage.messageId)")
        delegate?.messageError(message: self.currentMessage)
    }

    func routeLoaded(route: String) {
        Logger.instance.info(message: "Message loaded with route: \(route)")

        self.currentRoute = route
        if route == currentMessage.messageId && !messageLoaded {
            messageLoaded = true
            if isMessageEmbed {
                self.delegate?.messageShown(message: self.currentMessage)
            } else {
                if UIApplication.shared.applicationState == .active {
                    loadModalMessage()
                } else {
                    Gist.shared.removeMessageManager(instanceId: currentMessage.instanceId)
                }
            }
        }
    }

    deinit {
        engine?.cleanEngineWeb()
        engine = nil
    }

    private func showNewMessage(url: URL) {
        var properties: [String: Any]?

        if let stringProps = url.queryParameters?["properties"],
           let decodedData = Data(base64Encoded: stringProps),
           let decodedString = String(data: decodedData, encoding: .utf8),
           let convertedProps = convertToDictionary(text: decodedString) {
            properties = convertedProps
        }

        if let messageId = url.queryParameters?["messageId"] {
            _ = Gist.shared.showMessage(Message(messageId: messageId, properties: properties))
        }
    }

    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
