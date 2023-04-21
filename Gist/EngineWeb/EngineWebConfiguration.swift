import Foundation

struct EngineWebConfiguration: Encodable {
    let instanceId: String
    let endpoint: String
    let messageId: String
    let livePreview: Bool = false
    let properties: [String: AnyEncodable?]?
    let engineConfiguration: EngineConfiguration

    init(instanceId: String,
         endpoint: String,
         messageId: String,
         engineConfiguration: EngineConfiguration,
         properties: [String: AnyEncodable?]?) {
        self.messageId = messageId
        self.instanceId = instanceId
        self.endpoint = endpoint
        self.engineConfiguration = engineConfiguration
        self.properties = properties
    }
}
