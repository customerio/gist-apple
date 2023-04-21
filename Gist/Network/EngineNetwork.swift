import Foundation

class EngineNetwork {
    let siteId: String
    let dataCenter: String

    init(siteId: String, dataCenter: String) {
        self.siteId = siteId
        self.dataCenter = dataCenter
    }

    typealias GistNetworkResponse = (Data, HTTPURLResponse)

    func request(_ request: GistNetworkRequest,
                 completionHandler: @escaping (Result<GistNetworkResponse, Error>) -> Void) throws {
        guard let baseURL = URL(string: Settings.Network.engineAPI) else {
            throw GistNetworkRequestError.invalidBaseURL
        }

        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(request.path))
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.addValue(siteId, forHTTPHeaderField: HTTPHeader.siteId.rawValue)
        urlRequest.addValue(dataCenter, forHTTPHeaderField: HTTPHeader.cioDataCenter.rawValue)
        urlRequest.addValue(ContentTypes.json.rawValue, forHTTPHeaderField: HTTPHeader.contentType.rawValue)

        try BaseNetwork.request(request,
                                urlRequest: urlRequest,
                                baseURL: baseURL,
                                completionHandler: completionHandler)
    }
}
