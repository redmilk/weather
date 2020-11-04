//
//  ApiClient.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 30.10.2020.
//

import RxSwift
import RxCocoa
import CoreLocation
import MapKit

protocol ApiRequestable {
    func request(method: String,
                 pathComponent: String,
                 params: [(String, String)]) -> Observable<Data>
}

final class ApiClient: ApiRequestable {
    
    private let apiKey = BehaviorSubject<String>(value: "66687e09dee0508032ac82d5785ee2ad")
    private let baseURL = URL(string: "https://api.openweathermap.org/data/2.5")!
    
    init() {
        Logging.URLRequests = { request in
            return true
        }
    }
    
    func request(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
        let request = buildRequest(method: method, pathComponent: pathComponent, params: params)
        return processRequest(request)
    }
    
    private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> URLRequest {
        let url = baseURL.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "appid", value: try? apiKey.value())
        let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" {
            var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            queryItems.append(keyQueryItem)
            queryItems.append(unitsQueryItem)
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems = [keyQueryItem, unitsQueryItem]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        request.url = urlComponents.url!
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func processRequest(_ request: URLRequest) -> Observable<Data> {
        let session = URLSession.shared
        return session.rx.response(request: request).map { tuple in
            switch tuple.response.statusCode {
            case 200..<300:
                return tuple.data
            case 401:
                throw ApplicationErrors.ApiClient.invalidToken
            case 400..<500:
                throw ApplicationErrors.ApiClient.serverError
            default:
                throw ApplicationErrors.ApiClient.serverError
            }
        }
        
    }
}
