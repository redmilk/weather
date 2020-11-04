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

/// Access to state store
extension MainSceneViewController: StateStoreSupporting,
                                   LocationSupporting { }

final class MainSceneViewController: UIViewController, ReachabilitySupporting {
    
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
        
        reachability.startMonitor("google.com")
        reachability.status
            .subscribe()
            .disposed(by: bag)
        
        
        /// State Input
        let state = store
            .mainSceneState
            .observeOn(MainScheduler.instance)
        
                
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
            .flatMap { $0.isLoading }
            .startWith(false)
            .map { !$0 }
            .asDriver(onErrorJustReturn: false)
            .drive(activityIndicator.rx.isHidden)
            .disposed(by: bag)
        
        state
            .flatMap { $0.searchText }
            .asDriver(onErrorJustReturn: "Something went wrong")
            .drive(weatherIconLabel.rx.text)
            .disposed(by: bag)
        
        state
            .flatMap { $0.locationPermission }
            .filter { $0 == false }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.present(simpleAlertWith: "Warning", message: "Please provide location services permission in Settings app. Thank you, goodbye :]")
                    .subscribe()
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
        
        state
            .debug("🔴🔴🔴")
            .flatMap { $0.error }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] err in
                guard let self = self else { return }
                self.present(simpleAlertWith: "Error", message: err.localizedDescription)
                    .subscribe()
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
        
        /// Actions Output
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
    
    private func showError(text: String, requestRetryText: String) {
        errorLabel.text = text
        errorLabel.backgroundColor = .red
        retryCounterLabel.text = requestRetryText
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.errorLabel.text = ""
            self?.retryCounterLabel.text = ""
            self?.errorLabel.backgroundColor = .clear
        }
    }
}
