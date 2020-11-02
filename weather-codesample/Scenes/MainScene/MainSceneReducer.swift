//
//  MainSceneReducer.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Reducer
class MainSceneReducer: StateStoreAccessible {
    
    public var action = PublishRelay<ActionType>()
    
    public init() {
        self.action.subscribe(onNext: { [weak self] action in
            guard let self = self else { return }
            self.reduce(action: action, state: try! self.store.mainSceneState.value())
        })
        .disposed(by: bag)
    }
        
    private func reduce(action: ActionType, state: MainSceneState) {
        /// Request weather by city name
        if let weatherByCity = action as? GetWeatherByCityName {
            weatherByCity
                .weather
                .debug("🟧 Weather By City Request")
                .map({ weather in
                var newState = state
                newState.searchText = weather.name ?? "-"
                newState.temperature = weather.main?.temp?.description ?? "-"
                newState.humidity = weather.main?.humidity?.description ?? "-"
                newState.weatherIcon = weather.weather?.first?.icon ?? "-"
                return newState
            })
            .bind(to: store.mainSceneState)
            .disposed(by: bag)
        }
        /// Current location weather
        if let currentLocationWeather = action as? GetCurrentLocationWeather {
            currentLocationWeather.weather
                .debug("🟦 Weather at current location")
                .map ({ (weather) -> MainSceneState in
                    var newState = state
                    newState.searchText = weather.name ?? "-"
                    newState.temperature = weather.main?.temp?.description ?? "-"
                    newState.humidity = weather.main?.humidity?.description ?? "-"
                    newState.weatherIcon = weather.weather?.first?.icon ?? "-"
                    return newState
                })
                .bind(to: store.mainSceneState)
                .disposed(by: bag)
        }
    }
    
    private let bag = DisposeBag()
}
