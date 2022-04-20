//
//  CatApiClientAsync.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/18.
//

import Foundation

class CatApiClient {
    static let shared = CatApiClient()
    let baseURL = URL(string: "https://api.thecatapi.com/v1")!
    let urlSession: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "x-api-key": "DEMO-API-KEY"
        ]
        urlSession = URLSession(configuration: configuration)
    }
    
    
    func decode<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            
            if let apiErrorResponse = try? decoder.decode(ApiErrorResponse.self, from: data) {
                throw apiErrorResponse
            } else {
                throw CatApiError.requestFailed

            }
        }
        return try decoder.decode(T.self, from: data)
        
    }
    
    func fetchFavorites() async throws -> [Favorite] {
        guard let userId = User.current?.id else {
            throw CatApiError.userNotLogin
        }
        let url = baseURL.appendingPathComponent("favourites")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "sub_id", value: userId)
        ]
        let request = URLRequest(url: components.url!)
        let (data, response) = try await urlSession.data(for: request)
        return try decode(data: data, response: response)
        
    }
    
    func vote(imageId: String, value: VoteValue) async throws -> UpdateVote {
        guard let userId = User.current?.id else {
            throw CatApiError.userNotLogin
        }
        let url = baseURL.appendingPathComponent("votes")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        let body = UpdateVoteBody(imageId: imageId, subId: userId, value: value)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await urlSession.data(for: request)
        return try decode(data: data, response: response)
        
    }
}

