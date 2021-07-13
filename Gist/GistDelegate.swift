import UIKit

public protocol GistDelegate: AnyObject {
    func embedMessage(message: Message, elementId: String)
    func messageShown(message: Message)
    func messageDismissed(message: Message)
    func messageError(message: Message)
    func action(message: Message, currentRoute: String, action: String)
    func sizeChanged(message: Message, width: CGFloat, height: CGFloat)
}
