//
//  GetWeatherByCityName.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import RxSwift
import RxCocoa


extension GetWeatherByCityName: WeatherApiSupporting,
                                ReachabilitySupporting { }

class GetWeatherByCityName: ActionType {
    
    let cityName: String
    var weather: Observable<Weather> {
        return api.currentWeather(city: cityName)
    }
    
    init(cityName: String) {
        self.cityName = cityName
        
    }
    
}
