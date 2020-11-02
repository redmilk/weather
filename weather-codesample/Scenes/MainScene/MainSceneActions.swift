//
//  MainSceneActions.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 01.11.2020.
//

import Foundation
import RxSwift


struct GetWeatherByCityName: ActionType,
                             Networkingable {
    
    public var weather: Observable<Weather> {
        return apiClient.currentWeather(city: cityName).catchErrorJustReturn(Weather())
    }
    
    init(cityName: String) {
        self.cityName = cityName
    }
    
    private let cityName: String
}


struct GetCurrentLocationWeather: ActionType,
                                  Locationable,
                                  Networkingable {
    
    var weather: Observable<Weather> {
        return locationService.currentLocation.flatMap { location in
            apiClient.currentWeather(at: location.coordinate)
        }
        .do(onSubscribe: {
            locationService.requestPermission()
        })
        .catchErrorJustReturn(Weather())
    }
    
    private let bag = DisposeBag()
}
