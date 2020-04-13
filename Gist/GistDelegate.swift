public protocol GistDelegate: AnyObject {
    func messageShown(messageId: String)
    func messageDismissed(messageId: String)
    func messageError(messageId: String)
    func action(action: String)
}
