//
//  MainSceneViewController.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 30.10.2020.
//

import UIKit
import RxSwift
import RxCocoa


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
    
    private var state: Binder<MainSceneState> {
        return Binder<MainSceneState>(self) { (controller, state) in
            controller.updateState(state)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reachability.startMonitor("google.com")
        reachability.status
            .subscribe()
            .disposed(by: bag)
        
        /// Output
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .map { self.searchTextField.text ?? "" }
            .filter { !$0.isEmpty }
            .map { MainSceneIntent.Action.getWeatherBy(city: $0) }
            .bind(to: intent.action)
            .disposed(by: bag)
        
        /// Input
        store.mainSceneState
            .observeOn(MainScheduler.instance)
            .bind(to: state)
            .disposed(by: bag)
        
        store.mainSceneState
            .observeOn(MainScheduler.instance)
            .bind(to: state)
            .disposed(by: bag)
        
        locationButton.rx.controlEvent(.touchUpInside)
            .map { MainSceneIntent.Action.currentLocationWeather }
            .bind(to: intent.action)
            .disposed(by: bag)
    }
    
    private func updateState(_ state: MainSceneState) {
        searchTextField.text = state.searchText
        tempLabel.text = state.temperature
        humidityLabel.text = state.humidity
        weatherIconLabel.text = state.searchText
        activityIndicator.isHidden = !state.isLoading
        state.error
            .debug("🔴🔴🔴")
            .observeOn(MainScheduler.instance)
            .unwrap()
            .map { [weak self] in
                guard let self = self else { return }
                self.present(simpleAlertWith: state.retryCountText, message: $0.0)
                    .subscribe()
                    .disposed(by: self.bag)
            }
            .subscribe()
            .disposed(by: bag)
//        if let errText = state.error? {
//            showError(text: errText, requestRetryText: state.retryCountText)
//        }
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
