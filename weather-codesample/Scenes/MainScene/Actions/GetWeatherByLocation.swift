//
//  GetWeatherByLocation.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import RxSwift
import RxCocoa


extension GetCurrentLocationWeather: WeatherApiSupporting,
                                     LocationSupporting { }

struct GetCurrentLocationWeather: ActionType {
    
    var weather: Observable<Weather> {
        return locationService.currentLocation
            .map { ($0.coordinate.latitude, $0.coordinate.longitude) }
            .flatMap { api.currentWeather(at: $0.0, lon: $0.1) }
            .do(onSubscribe: {
                locationService.requestPermission()
            })
            .take(1)
            .catchErrorJustReturn(Weather())
    }
    
    private let bag = DisposeBag()
}
