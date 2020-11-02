//
//  MainSceneViewController.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 30.10.2020.
//

import UIKit
import RxSwift
import RxCocoa


extension MainSceneViewController: StateStoreAccessible { }

final class MainSceneViewController: UIViewController {
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tempLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var weatherIconLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationButton: UIButton!
    
    private var intent = MainSceneIntent(reducer: MainSceneReducer())
    private let bag = DisposeBag()
    private var stateBinder: Binder<MainSceneState> {
        return Binder<MainSceneState>(self) { (controller, state) in
            controller.updateState(state)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Output
        searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .debug("🔸 SearchTextField editingDidEndOnExit")
            .map { self.searchTextField.text ?? "" }
            .filter { !$0.isEmpty }
            .map { MainSceneIntent.Action.getWeatherBy(city: $0) }
            .bind(to: intent.action)
            .disposed(by: bag)
        
        /// Input
        store.mainSceneState
            .debug("⚪️ SearchTextField mainSceneState")
            .observeOn(MainScheduler.instance)
            .bind(to: stateBinder)
            .disposed(by: bag)
        
        locationButton.rx.controlEvent(.touchUpInside)
            .debug("🟠 Button Pressed")
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
    }
}
