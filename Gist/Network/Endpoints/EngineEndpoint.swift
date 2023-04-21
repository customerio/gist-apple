import Foundation

enum EngineEndpoint: GistNetworkRequest {
    case getEngineConfiguration(engineVersion: Int, version: Int)

    var method: HTTPMethod {
        switch self {
        case .getEngineConfiguration:
            return .post
        }
    }

    var parameters: RequestParameters? {
        switch self {
        case .getEngineConfiguration(let engineVersion, let version):
            return .body(EngineConfigurationRequest(engineVersion: engineVersion,
                                                    version: version))
        }
    }


    var path: String {
        switch self {
        case .getEngineConfiguration:
            return "/api/v2/configuration"
        }
    }
}
