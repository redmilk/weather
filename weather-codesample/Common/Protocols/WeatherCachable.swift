//
//  WeatherCachable.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 03.11.2020.
//

import Foundation

protocol WeatherCachable {
    func cacheWeather(_ w: Weather, with key: String)
}
