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
extension MainSceneViewController: StateStoreSupporting, NetworkSupporting { }


final class MainSceneViewController: UIViewController {
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tempLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var weatherIconLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    private var intent = MainSceneIntent(reducer: MainSceneReducer())
    private let bag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Actions
        locationButton.rx.controlEvent(.touchUpInside)
            .map { MainSceneIntent.Action.currentLocationWeather }
            .bind(to: intent.action)
            .disposed(by: bag)
        
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchTextField.text ?? nil }
            .unwrap()
            .map { MainSceneIntent.Action.getWeatherBy(city: $0) }
            .bind(to: intent.action)
            .disposed(by: bag)
        
        /// State Input
        let state = store
            .mainSceneState
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
        
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
        
        /// Request retry text
        state
            .flatMap { $0.requestRetryText }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                self?.errorLabel.text = msg
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self?.errorLabel.text = ""
                }
            })
            .disposed(by: bag)
        
        /// Error handling happens in Reducer and VC gets only data to present
        /// VC concerns about how to present different types of error
        state.flatMap { $0.errorAlertContent }
            .unwrap()
            .filter { !$0.0.isEmpty && !$0.1.isEmpty }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (errorData: (msg: String, title: String)) -> Void in
                guard let self = self else { return }
                if errorData.title == "No location access" {
                    self.present(alertWithActionAndText: errorData.msg, title: errorData.title, actionTitle: "Go to Settings") {
                        Helper.openSettings()
                    }
                    .subscribe()
                    .disposed(by: self.bag)
                } else {
                    self.present(simpleAlertWithText: errorData.msg, title: errorData.title)
                        .subscribe()
                        .disposed(by: self.bag)
                }
            })
            .disposed(by: bag)
    }
    
}
