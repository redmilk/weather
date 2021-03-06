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
                            NetworkSupporting,
                            WeatherApiSupporting { }

class MainSceneReducer {
    
    enum Action {
        case getWeatherBy(city: String)
        case currentLocationWeather
        case none
    }
    
    /// Input
    var action = PublishSubject<Action>()
    
    init() {
        /// Output to state storage
        actualState
            .asObservable()
            .bind(to: store.mainSceneState)
            .disposed(by: bag)
        
        /// Dispatching actions
        action.asObservable()
            .subscribe(onNext: { [weak self] action in
                guard let self = self else { return }
                
                let newState = (try? self.actualState.value()) ?? self.formatting.mainSceneFormatter.format(state: .initial)
                newState.requestRetryText.onNext(ApiClient.requestRetryMessage.value)
                
                switch action {
                
                /// city search weather
                case .getWeatherBy(let city):
                    if self.reachability.status.value != .online {
                        newState.errorAlertContent.onNext(self.handleError(ApplicationErrors.Network.noConnection))
                        newState.errorAlertContent.onNext(nil)
                    }
                    self.loadWeather(self.weatherApi.currentWeather(city: city), state: newState)
                    
                /// current location weather
                case .currentLocationWeather:
                    self.locationService.requestPermission()
                    if self.reachability.status.value != .online {
                        newState.errorAlertContent.onNext(self.handleError(ApplicationErrors.Network.noConnection))
                        newState.errorAlertContent.onNext(nil)
                    }
                    guard self.locationService.locationServicesEnabled() else {
                        newState.errorAlertContent.onNext(self.handleError(ApplicationErrors.Location.noPermission))
                        newState.errorAlertContent.onNext(nil)
                        return
                    }
                    self.loadWeather(self.currentLocationWeather, state: newState)
                    
                case .none:
                    break
                }
            })
            .disposed(by: bag)
        
        /// for debug
        ApiClient.requestRetryMessage
            .filter { !$0.isEmpty }
            .subscribe(onNext: { msg in
                let state = try? self.actualState.value()
                state?.requestRetryText.onNext(msg)
            })
        .disposed(by: bag)
    }
    
    /// Internal
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
                //let cachedWeather: Weather = Weather()
                //state.updateWeather(<#T##weather: Weather##Weather#>)
                return Observable.just(state)
            }
            .bind(to: self.actualState)
            .disposed(by: self.bag)
    }
    
    private var currentLocationWeather: Observable<Weather> {
       return self.locationService.currentLocation
            .map { ($0.coordinate.latitude, $0.coordinate.longitude) }
            .flatMap { self.weatherApi.currentWeather(at: $0.0, lon: $0.1) }
    }
    
    private lazy var actualState: BehaviorSubject<MainSceneState> = {
        let formatted = formatting.mainSceneFormatter.format(state: .initial)
        let state = BehaviorSubject<MainSceneState>(value: formatted)
        return state
    }()
    
    private let bag = DisposeBag()
}


// MARK: Error handling
extension MainSceneReducer: ErrorHandling {
    func handleError(_ error: Error) -> (String, String)? {
        switch error {
        case let request as ApplicationErrors.ApiClient:
            switch request {
            case .notFound:
                return ("City not found", "😰")
            case .serverError:
                return ("Something went wrong", "Server error")
            case .invalidToken:
                return ("Token is invalid", "Required authentication")
            case .invalidResponse:
                return ("Request failure", "Ivalid response")
            case .deserializationFailed:
                return ("Deserialization failure", "Decodable fail")
            }
        case let location as ApplicationErrors.Location:
            switch location {
            case .noPermission:
                return ("Please provide access to location services in Settings app", "No location access")
            }
        case let network as ApplicationErrors.Network:
            switch network {
            case .noConnection:
                return ("Looking for internet connection...", "Internet connection failure")
            }
        default: break
        }
        return nil
    }
}
