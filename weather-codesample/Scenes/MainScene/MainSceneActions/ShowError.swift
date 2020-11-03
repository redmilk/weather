//
//  ShowError.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 03.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

struct ShowError: ActionType {
    
    private let alertPresenter: UIViewController
    private let errorText: String
    
    init(alertPresenter: UIViewController, text: String) {
        self.alertPresenter = alertPresenter
        self.errorText = text
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alertPresenter.present(alert, animated: true) { }
    }
    
}
