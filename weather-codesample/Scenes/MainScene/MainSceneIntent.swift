//
//  MainSceneIntent.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import RxSwift
import RxCocoa

/// Get UI events and produce according actions to reducer

class MainSceneIntent {
    
    enum Action {
        case getWeatherBy(city: String)
        case currentLocationWeather
        case none
    }
    
    var action = PublishSubject<Action>()
   
    init(reducer: MainSceneReducer) {
        self.reducer = reducer
        self.action.asObservable()
            .subscribe(onNext: { [weak self] action in
                self?.dispatch(action: action)
            })
            .disposed(by: bag)
    }
    
    private let reducer: MainSceneReducer
    private let bag = DisposeBag()
    private func dispatch(action: Action) {
        switch action {
        case .getWeatherBy(let city):
            reducer.incomingAction.onNext(GetWeatherByCityName(cityName: city))
        case .currentLocationWeather:
            reducer.incomingAction.onNext(GetCurrentLocationWeather())
        case .none: break
        }
    }
    
}
