//
//  MainSceneState.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import Foundation

// MARK: State
struct MainSceneState: State {
    var searchText: String
    var temperature: String
    var humidity: String
    var weatherIcon: String
    var isLoading: Bool
    
    static let initial: MainSceneState = {
        return MainSceneState(
            searchText: "-",
            temperature: "TEMP",
            humidity: "HUM",
            weatherIcon: "ICON",
            isLoading: false
        )
    }()
    
}
