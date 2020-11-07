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
                            LocationSupporting,
                            FormattingSupporting { }

class MainSceneReducer {
    
    /// Input
    var incomingAction: Binder<ActionType> {
        return Binder<ActionType>(self) { (reducer, action) in
            reducer.reduce(action: action)
        }
    }
    
    init() {
        let initialState = (try? store.mainSceneState.value()) ?? .initial
        self.store.mainSceneState
            .asObserver()
            .onNext(formatting.mainSceneFormatter.format(state: initialState))
    }
    
    private let bag = DisposeBag()

    private func reduce(action: ActionType) {
        let newState = (try? store.mainSceneState.value()) ?? formatting.mainSceneFormatter.format(state: .initial)
        
        switch action {
        ///
        /// Request weather by city name
        ///
        case let getWeather as GetWeatherByCityName:
            newState.isLoading.onNext(true)
            weatherAction(getWeather.weather, state: newState)
        ///
        /// Request weather by current location
        ///
        case let locationWeather as GetCurrentLocationWeather:
            newState.isLoading.onNext(true)
            do {
                let locationPermission: Bool = try locationService.isLocationPermissionGranted.value()
                newState.locationPermission.onNext(locationPermission)
            } catch let error {
                newState.errorAlertContent.onNext(self.handleError(error))
                newState.errorAlertContent.onNext(("", ""))
                newState.isLoading.onNext(false)
            }
            weatherAction(locationWeather.weather, state: newState)
            
        default: break
        }
    }
    
    private func weatherAction(_ weather: Observable<Weather>, state: MainSceneState) {
        return weather.asObservable()
            .take(1)
            .map { (weather) -> MainSceneState in
                state.isLoading.onNext(false)
                state.updateWeather(weather)
                return state
            }
            .do(onError: { _ in
                state.isLoading.onNext(false)
            })
            .map { self.formatting.mainSceneFormatter.format(state: $0) }
            .catchError { [weak self] error in
                guard let self = self else { return Observable.just(state) }
                //let errorState = self.formatting.mainSceneFormatter.format(state: .initial)
                state.errorAlertContent.onNext(self.handleError(error))
                return Observable.just(state)
            }
            .bind(to: self.store.mainSceneState)
            .disposed(by: self.bag)
    }
}

// MARK: Error handling
extension MainSceneReducer: ErrorHandling {
    func handleError(_ error: Error) -> (String, String) {
        switch error {
        case let request as ApplicationErrors.ApiClient:
            switch request {
            case .notFound: return ("City not found", ":[")
            case .serverError: return ("Something went wrong", "Server error")
            case .invalidToken: return ("Token is invalid", "Required authentication")
            }
        case let location as ApplicationErrors.Location:
            switch location {
            case .noPermission: return ("Please provide access to location services in Settings app", "No permission")
            }
        case let network as ApplicationErrors.Network:
            switch network {
            case .noConnection:  return ("Looking for internet connection...", "Internet connection failure")
            }
        default: break
        }
        return ("", "")
    }
}
