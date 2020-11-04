//
//  MainSceneReducer.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import RxSwift
import RxCocoa
import Foundation


// MARK: Reducer
extension MainSceneReducer: StateStoreSupporting,
                            ReachabilitySupporting { }

class MainSceneReducer {
    
    /// Input
    var incomingAction: Binder<ActionType> {
        return Binder<ActionType>(self) { (reducer, action) in
            reducer.reduce(action: action)
        }
    }
    
    private let bag = DisposeBag()

    private func reduce(action: ActionType) {
        let newState = store.mainSceneState.value
        reachability.status
            .map { $0 == .online }
            .bind(to: newState.locationPermission)
            .disposed(by: bag)
        
        let maxRetryTimes = 4
        let retryHandler: (Observable<Error>) -> Observable<Int> = { err in
            return err.enumerated().flatMap { count, error -> Observable<Int> in
                /// attempts left
                if count >= maxRetryTimes - 1 {
                    return Observable.error(error)
                    /// if connection is offline
                } else if (error as NSError).code == -1009 {
                    return self.reachability
                        .status
                        .skip(1)
                        .map { (status: Reachability.Status) -> Bool in
                            return status == .online
                        }
                        .distinctUntilChanged()
                        .filter { $0 == true }
                        .map { _ in 1 }
                }
                newState.error.accept(error)
                newState.retryCountText.accept("🔄 REQUEST RETRY LEFT: \(maxRetryTimes - count - 1)")
                self.store.mainSceneState.accept(newState)
                return Observable<Int>
                    .timer(Double(count + 2), scheduler: MainScheduler.instance)
                    .take(1)
            }
        }
        
        let weatherRequest: (Observable<Weather>) -> Void = { [weak self] weather in
            guard let self = self else { return }
            return weather.asObservable()
                .debug("🟧 Weather By City Request")
                .retryWhen(retryHandler)
                .materialize()
                .map { (event) -> MainSceneState in
                    newState.isLoading.accept(false)
                    if let weather = event.element {
                        newState.updateWeather(weather)
                    }
                    if let error = event.error {
                        newState.error.accept(error)
                    }
                    return newState
                }
                .bind(to: self.store.mainSceneState)
                .disposed(by: self.bag)
        }
        
        switch action {
        ///
        /// Request weather by city name
        ///
        case let getWeather as GetWeatherByCityName:
            newState.isLoading.accept(true)
            weatherRequest(getWeather.weather)
        ///
        /// Current location weather
        ///
        case let locationWeather as GetCurrentLocationWeather:
            newState.isLoading.accept(true)
            weatherRequest(locationWeather.weather)
            
        default: break
        }
    }
}
