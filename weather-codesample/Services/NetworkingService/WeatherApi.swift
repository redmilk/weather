//
//  WeatherApi.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 04.11.2020.
//

import RxSwift

struct WeatherApi {
    
    private let api: ApiRequestable
    
    init(requestable: ApiRequestable) {
        self.api = requestable
    }
    
    func currentWeather(city: String) -> Observable<Weather> {
        return api
            .request(method: "GET",
                     pathComponent: "weather",
                     params: [("q", city)]
            )
            .map { data in
                let decoder = JSONDecoder()
                return try decoder.decode(Weather.self, from: data)
            }
    }
    
    func currentWeather(at lat: Double, lon: Double) -> Observable<Weather> {
        return api
            .request(method: "GET",
                     pathComponent: "weather",
                     params: [("lat", "\(lat)"), ("lon", "\(lon)")])
            .map { data in
                let decoder = JSONDecoder()
                return try decoder.decode(Weather.self, from: data)
            }
    }
}
