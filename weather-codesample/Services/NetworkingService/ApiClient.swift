//
//  ApiClient.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 30.10.2020.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import MapKit

final class ApiController {

  /// The api key to communicate with openweathermap.org
  /// Create you own on https://home.openweathermap.org/users/sign_up
  private let apiKey = "66687e09dee0508032ac82d5785ee2ad"

  /// API base URL
  let baseURL = URL(string: "https://api.openweathermap.org/data/2.5")!

  init() {
    Logging.URLRequests = { request in
      return true
    }
  }

  // MARK: - Api Calls
  func currentWeather(city: String) -> Observable<Weather> {
    return buildRequest(pathComponent: "weather", params: [("q", city)])
      .map { data in
        let decoder = JSONDecoder()
        return try decoder.decode(Weather.self, from: data)
      }
  }

  func currentWeather(at coordinate: CLLocationCoordinate2D) -> Observable<Weather> {
    return buildRequest(pathComponent: "weather", params: [("lat", "\(coordinate.latitude)"),
                                                           ("lon", "\(coordinate.longitude)")])
      .map { data in
        let decoder = JSONDecoder()
        return try decoder.decode(Weather.self, from: data)
      }
  }

  // MARK: - Private Methods

  /**
   * Private method to build a request with RxCocoa
   */
  private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
    let url = baseURL.appendingPathComponent(pathComponent)
    var request = URLRequest(url: url)
    let keyQueryItem = URLQueryItem(name: "appid", value: apiKey)
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

    let session = URLSession.shared

    return session.rx.data(request: request)
  }

}

/**
 * Maps an icon information from the API to a local char
 * Source: http://openweathermap.org/weather-conditions
 */
//public func iconNameToChar(icon: String) -> String {
//  switch icon {
//  case "01d":
//    return "\u{f11b}"
//  case "01n":
//    return "\u{f110}"
//  case "02d":
//    return "\u{f112}"
//  case "02n":
//    return "\u{f104}"
//  case "03d", "03n":
//    return "\u{f111}"
//  case "04d", "04n":
//    return "\u{f111}"
//  case "09d", "09n":
//    return "\u{f116}"
//  case "10d", "10n":
//    return "\u{f113}"
//  case "11d", "11n":
//    return "\u{f10d}"
//  case "13d", "13n":
//    return "\u{f119}"
//  case "50d", "50n":
//    return "\u{f10e}"
//  default:
//    return "E"
//  }
//}


