//
//  MainSceneIntent.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import Foundation
import RxSwift
import RxCocoa

class MainSceneIntent {
    
    enum Action {
        case getWeatherBy(city: String)
        case currentLocationWeather
    }
    
    public var action: PublishRelay<Action>
   
    init(reducer: MainSceneReducer = MainSceneReducer()) {
        self.reducer = reducer
        self.action = PublishRelay<Action>()
        self.action.asObservable()
            .subscribe(onNext: { [weak self] action in
                self?.dispatch(action: action)
            })
            .disposed(by: bag)
    }
    
    /// Internal
    private let reducer: MainSceneReducer
    private let bag = DisposeBag()
    
    private func dispatch(action: Action) {
        switch action {
        case .getWeatherBy(let city):
            reducer.action.accept(GetWeatherByCityName(cityName: city))
        case .currentLocationWeather:
            reducer.action.accept(GetCurrentLocationWeather())
        }
    }
    
}
