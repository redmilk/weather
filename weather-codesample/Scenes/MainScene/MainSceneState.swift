//
//  MainSceneState.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import CoreLocation
import RxCocoa
import RxSwift

// MARK: State
struct MainSceneState: StateType {
 
    var searchText = PublishRelay<String>()
    var temperature = PublishRelay<String>()
    var humidity = PublishRelay<String>()
    var weatherIcon = PublishRelay<String>()
    var isLoading = PublishRelay<Bool>()
    var location = PublishRelay<CLLocationCoordinate2D?>()
    var error = PublishRelay<Error>()
    var retryCountText = PublishRelay<String>()
    var locationPermission = PublishRelay<Bool>()
   
    func updateWeather(_ weather: Weather) {
        searchText.accept(weather.name ?? "-")
        temperature.accept(weather.main?.temp?.description ?? "-")
        humidity.accept(weather.main?.humidity?.description ?? "-")
        weatherIcon.accept(weather.weather?.first?.icon ?? "-")
    }
        
    func copy() -> MainSceneState {
        var state = MainSceneState()
        state.searchText = self.searchText
        state.temperature = self.temperature
        state.humidity = self.humidity
        state.weatherIcon = self.weatherIcon
        state.isLoading = self.isLoading
        state.location = self.location
        state.error = self.error
        state.retryCountText = self.retryCountText
        return state
    }
    
    static var initial: MainSceneState {
        let state = MainSceneState()
        state.searchText.accept("Dnipro")
        state.weatherIcon.accept("Initial")
        state.temperature.accept("999")
        state.humidity.accept("100.0")
        return state
    }
}
