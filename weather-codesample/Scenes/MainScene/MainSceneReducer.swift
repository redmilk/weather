//
//  MainSceneReducer.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import RxSwift
import RxCocoa
import Foundation
import CoreLocation


// MARK: Reducer
extension MainSceneReducer: StateStoreSupporting,
                            LocationSupporting,
                            FormattingSupporting,
                            ReachabilitySupporting,
                            NetworkSupporting { }

class MainSceneReducer {
    
    /// Input
    var incomingAction: Binder<ActionType> {
        return Binder<ActionType>(self) { (reducer, action) in
            reducer.reduce(action: action)
        }
    }
    
    lazy var actualState: BehaviorSubject<MainSceneState> = {
        let formatted = formatting.mainSceneFormatter.format(state: .initial)
        let state = BehaviorSubject<MainSceneState>(value: formatted)
        return state
    }()
    
    init() {
        /// bind state to state store
        actualState
            .asObservable()
            .bind(to: store.mainSceneState)
            .disposed(by: bag)
        
        ApiClient.requestRetryMessage
            .filter { !$0.isEmpty }
            .subscribe(onNext: { msg in
                let state = try? self.actualState.value()
                state?.requestRetryText.onNext(msg)
            })
        .disposed(by: bag)
    }
    
    private let bag = DisposeBag()

    private func reduce(action: ActionType) {
        let newState = (try? actualState.value()) ?? formatting.mainSceneFormatter.format(state: .initial)
        newState.requestRetryText.onNext(ApiClient.requestRetryMessage.value)
        
        switch action {
        
        /// Request weather by city name
        case let getWeather as GetWeatherByCityName:
            if reachability.status.value != .online {
                newState.errorAlertContent.onNext(self.handleError(ApplicationErrors.Network.noConnection))
                newState.errorAlertContent.onNext(nil)
            }
            loadWeather(getWeather.weather, state: newState)
            
        /// Request weather by current location
        case let locationWeather as GetCurrentLocationWeather:
            if reachability.status.value != .online {
                newState.errorAlertContent.onNext(self.handleError(ApplicationErrors.Network.noConnection))
                newState.errorAlertContent.onNext(nil)
            }
            guard locationService.locationServicesEnabled() else {
                newState.errorAlertContent.onNext(self.handleError(ApplicationErrors.Location.noPermission))
                newState.errorAlertContent.onNext(nil)
                return
            }
            loadWeather(locationWeather.weather, state: newState)
            
        default: break
        }
    }
    
    private func loadWeather(_ weather: Observable<Weather>, state: MainSceneState) {
        state.isLoading.onNext(true)
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
                state.errorAlertContent.onNext(self.handleError(error))
                state.errorAlertContent.onNext(nil)
                return Observable.just(state)
            }
            .bind(to: self.actualState)
            .disposed(by: self.bag)
    }
}

// MARK: Error handling
extension MainSceneReducer: ErrorHandling {
    func handleError(_ error: Error) -> (String, String)? {
        switch error {
        case let request as ApplicationErrors.ApiClient:
            switch request {
            case .notFound: return ("City not found", ":[")
            case .serverError: return ("Something went wrong", "Server error")
            case .invalidToken: return ("Token is invalid", "Required authentication")
            }
        case let location as ApplicationErrors.Location:
            switch location {
            case .noPermission: return ("Please provide access to location services in Settings app", "No location access")
            }
        case let network as ApplicationErrors.Network:
            switch network {
            case .noConnection:  return ("Looking for internet connection...", "Internet connection failure")
            }
        default: break
        }
        return nil
    }
}
