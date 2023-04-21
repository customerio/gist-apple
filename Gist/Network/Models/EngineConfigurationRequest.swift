import Foundation

struct EngineConfigurationRequest: Encodable {
    let engineVersion: Int
    let version: Int

    init(engineVersion: Int, version: Int) {
        self.engineVersion = engineVersion
        self.version = version
    }
}
