import Foundation

struct EngineConfiguration: Encodable {
    let projectId: String
    let organizationId: String
    var configuration = [String: AnyEncodable?]()

    init(projectId: String,
         organizationId: String,
         configuration: [String: AnyEncodable?]) {
        self.projectId = projectId
        self.organizationId = organizationId
        self.configuration = configuration
    }
    
    init(projectId: String, organizationId: String, configuration: [String: Any]) {
        self.projectId = projectId
        self.organizationId = organizationId
        
        configuration.keys.forEach { key in
            if let value = configuration[key] {
                self.configuration[key] = AnyEncodable(value)
            }
        }
    }
}
