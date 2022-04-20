//
// APIRequest.swift
//

import UIKit

protocol APIRequest {
    associatedtype Response
    
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var request: URLRequest { get }
    var data: Data? { get }
    var method: HTTPMethod { get }
    var multipartDic: [String: Any]? { get }

}

extension APIRequest {
    var host: String { "api.thecatapi.com" }
    var queryItems: [URLQueryItem]? { nil }
    var data: Data? { nil }
    var multipartDic: [String: Any]? { nil }

    
}

extension APIRequest {
    var request: URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/v1" + path
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        request.httpBody = data
        if let multipartDic = multipartDic {
            request.createMultipartFormData(parameters: multipartDic)
        } else if method == .post || method == .put {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}


extension APIRequest where Response: Decodable {
    
    func send() async throws -> Response {
        let (data, response) = try await URLSession.catAPI.data(for: request)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...201 ~= httpResponse.statusCode else {
            
            if let apiErrorResponse = try? decoder.decode(ApiErrorResponse.self, from: data) {
                throw apiErrorResponse
            } else {
                throw CatApiError.requestFailed

            }
        }
        return try decoder.decode(Response.self, from: data)
    }
    
    func send(completion: @escaping (Result<Response, Error>) -> Void) {
        URLSession.catAPI.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                guard let httpResponse = response as? HTTPURLResponse,
                      200...201 ~= httpResponse.statusCode else {
                    
                    if let apiErrorResponse = try? decoder.decode(ApiErrorResponse.self, from: data) {
                        completion(.failure(apiErrorResponse))
                    } else {
                        completion(.failure(CatApiError.requestFailed))
                    }
                    return
                }
                
                do {
                    let decoded = try decoder.decode(Response.self, from: data)
                    completion(.success(decoded))
                } catch  {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
            
        }.resume()
    }
}


