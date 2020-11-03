//
//  MainSceneState.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import CoreLocation
import RxCocoa

// MARK: State
struct MainSceneState: StateType {
    // TODO: Observables
    // TODO: Observables
    // TODO: Observables
    // TODO: Observables
    // TODO: Observables

    var searchText: String
    var temperature: String
    var humidity: String
    var weatherIcon: String
    var isLoading: Bool
    
    var location: CLLocationCoordinate2D?
    
    var error = PublishRelay<(String, Error)?>()
    var retryCountText: String = ""
    
    mutating func updateWeather(_ weather: Weather) {
        searchText = weather.name ?? ""
        temperature = weather.main?.temp?.description ?? ""
        humidity = weather.main?.humidity?.description ?? "-"
        weatherIcon = weather.weather?.first?.icon ?? "-"
    }
    
    static let initialState = MainSceneState(
        searchText: "Yalta",
        temperature: "-999",
        humidity: "00.0",
        weatherIcon: ":]",
        isLoading: false,
        location: nil
    )
}
