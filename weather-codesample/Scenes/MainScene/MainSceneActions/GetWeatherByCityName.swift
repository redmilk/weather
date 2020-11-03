//
//  GetWeatherByCityName.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import RxSwift
import RxCocoa


extension GetWeatherByCityName: NetworkSupporting,
                                ReachabilitySupporting { }

class GetWeatherByCityName: ActionType {
    
    let cityName: String
    var weather: Observable<Weather> {
        return apiClient.currentWeather(city: cityName)
    }
    
    init(cityName: String) {
        self.cityName = cityName
        
    }
    
}
