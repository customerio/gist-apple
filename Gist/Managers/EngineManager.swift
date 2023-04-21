import Foundation

class EngineManager {
    let siteId: String
    let dataCenter: String

    init(siteId: String, dataCenter: String) {
        self.siteId = siteId
        self.dataCenter = dataCenter
    }

    func bootstrapEngine() {
        fetchEngineConfiguration(completionHandler: { response in
            switch response {
            case .success(let engineConfigurationResponse):
                Gist.shared.engineConfiguration = engineConfigurationResponse.toEngineConfiguration()
            case .failure(_):
                break
            }})
    }
    
    private func fetchEngineConfiguration(completionHandler: @escaping (Result<EngineConfigurationResponse, Error>) -> Void) {
        do {
            try EngineNetwork(siteId: siteId, dataCenter: dataCenter)
                .request(EngineEndpoint.getEngineConfiguration(engineVersion: 1, version: 1), completionHandler: { response in
                switch response {
                case .success(let (data, _)):
                    do {
                        guard let engineConfigurationResponse =
                            try JSONSerialization.jsonObject(with: data,
                                                             options: .allowFragments) as? [String: Any] else {
                            completionHandler(.failure(GistNetworkError.requestFailed))
                            return
                        }
                        DispatchQueue.main.async {
                            if let engineConfiguration = EngineConfigurationResponse(dictionary: engineConfigurationResponse) {
                                completionHandler(.success(engineConfiguration))
                            }
                        }
                    } catch {
                        completionHandler(.failure(error))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }})
        } catch {
            completionHandler(.failure(error))
        }
    }
}
