//
//  MainSceneActions.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 01.11.2020.
//

import Foundation
import RxSwift


struct GetWeatherByCityName: ActionType {
    
    public var weather: Observable<Weather> {
        return ApiController.shared.currentWeather(city: cityName).catchErrorJustReturn(Weather())
    }
    
    init(apiController: ApiController = ApiController.shared,
         cityName: String
    ) {
        self.apiController = apiController
        self.cityName = cityName
    }
    
    /// Internal
    private let apiController: ApiController
    private let cityName: String
}


struct GetCurrentLocationWeather: ActionType {
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    var weather: Observable<Weather> {
        return locationService.currentLocation.flatMap {
            ApiController.shared.currentWeather(at: $0.coordinate)
        }
    }
    
    private let locationService: LocationService
    private let bag = DisposeBag()
}
