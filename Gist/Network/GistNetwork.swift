import Foundation

class GistNetwork {
    let organizationId: String

    init(organizationId: String) {
        self.organizationId = organizationId
    }

    func request(_ request: GistNetworkRequest,
                 completionHandler: @escaping (Result<GistNetworkResponse, Error>) -> Void) throws {
        guard let baseURL = URL(string: Settings.Network.gistAPI) else {
            throw GistNetworkRequestError.invalidBaseURL
        }

        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(request.path))
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.addValue(organizationId, forHTTPHeaderField: HTTPHeader.organizationId.rawValue)
        urlRequest.addValue(ContentTypes.json.rawValue, forHTTPHeaderField: HTTPHeader.contentType.rawValue)

        try BaseNetwork.request(request,
                                urlRequest: urlRequest,
                                baseURL: baseURL,
                                completionHandler: completionHandler)
    }
}
