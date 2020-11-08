//
//  MainSceneViewController.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 30.10.2020.
//

import UIKit
import RxSwift
import RxCocoa

// TODO: - Provide different error types and handle them at once in VC
// TODO: - Location permission Alert
// TODO: - Show info view on request retry
// TODO: - Maybe state should be shared, some of observables must be shared to prevent multiple handlers executing
// TODO: - Cache/Fetch cache on error
// TODO: - Letter appear animation

/// Access to state store
extension MainSceneViewController: StateStoreSupporting { }


final class MainSceneViewController: UIViewController {
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tempLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var weatherIconLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var retryCounterLabel: UILabel!
    
    private var intent = MainSceneIntent(reducer: MainSceneReducer())
    private let bag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /// State Input
        let state = store
            .mainSceneState
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
        
        /// Error handling
        state.flatMap { $0.errorAlertContent }
            .unwrap()
            .filter { !$0.0.isEmpty && !$0.1.isEmpty }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] tuple in
                guard let self = self else { return }
                self.present(simpleAlertWithText: tuple.0, title: tuple.1)
                    .subscribe()
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
            
        
        state
            .flatMap { $0.searchText }
            .asDriver(onErrorJustReturn: "")
            .drive(searchTextField.rx.text)
            .disposed(by: bag)
        
        state
            .flatMap { $0.temperature }
            .asDriver(onErrorJustReturn: "")
            .drive(tempLabel.rx.text)
            .disposed(by: bag)
        
        state
            .flatMap { $0.humidity }
            .asDriver(onErrorJustReturn: "")
            .drive(humidityLabel.rx.text)
            .disposed(by: bag)
        
        state
            .flatMap { $0.searchText }
            .asDriver(onErrorJustReturn: "")
            .drive(weatherIconLabel.rx.text)
            .disposed(by: bag)

        let loading = state
            .flatMap { $0.isLoading }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)
        
        loading
            .map { !$0 }
            .drive(activityIndicator.rx.isHidden)
            .disposed(by: bag)
        
        loading
            .map { !$0 }
            .drive(locationButton.rx.isEnabled)
            .disposed(by: bag)
        
        loading
            .map { !$0 }
            .drive(searchTextField.rx.isEnabled)
            .disposed(by: bag)
        
        /// Actions
        locationButton.rx.controlEvent(.touchUpInside)
            .map { MainSceneIntent.Action.currentLocationWeather }
            .bind(to: intent.action)
            .disposed(by: bag)
        
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchTextField.text ?? "" }
            .filter { !$0.isEmpty }
            .map { MainSceneIntent.Action.getWeatherBy(city: $0) }
            .bind(to: intent.action)
            .disposed(by: bag)

    }
}
