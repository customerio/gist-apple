import Foundation

struct EngineConfigurationResponse {
    let projectId: String
    let organizationId: String
    let configuration: [String: Any]

    init(projectId: String, organizationId: String, configuration: [String: Any]) {
        self.projectId = projectId
        self.organizationId = organizationId
        self.configuration = configuration
    }

    init?(dictionary: [String: Any]) {
        guard let projectId = dictionary["projectId"] as? String,
              let organizationId = dictionary["organizationId"] as? String,
              let configuration = dictionary["configuration"] as? [String: Any] else {
            return nil
        }
        self.init(projectId: projectId,
                  organizationId: organizationId,
                  configuration: configuration)
    }

    func toEngineConfiguration() -> EngineConfiguration {
        return EngineConfiguration(projectId: self.projectId,
                                   organizationId: self.organizationId,
                                   configuration: self.configuration)
    }
}
