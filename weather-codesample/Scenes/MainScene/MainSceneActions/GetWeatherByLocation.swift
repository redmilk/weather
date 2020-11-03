//
//  GetWeatherByLocation.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import RxSwift
import RxCocoa

struct GetCurrentLocationWeather: ActionType,
                                  LocationSupporting,
                                  NetworkSupporting {
    
    var weather: Observable<Weather> {
        return locationService.currentLocation.flatMap { location in
            apiClient.currentWeather(at: location.coordinate)
        }
        .do(onSubscribe: {
            locationService.requestPermission()
        })
        .take(1)
        .catchErrorJustReturn(Weather())
    }
    
    private let bag = DisposeBag()
}
