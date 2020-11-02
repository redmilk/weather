//
//  StateStore.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 01.11.2020.
//

import Foundation
import RxSwift
import RxCocoa


protocol StateStoreAccessible { }

extension StateStoreAccessible {
    var store: StateStore {
        return (UIApplication.shared.delegate as! AppDelegate).stateStore
    }
}



final class StateStore {
    
    public let mainSceneState: BehaviorSubject<MainSceneState>
    
    init(initialState: MainSceneState) {
        mainSceneState = BehaviorSubject<MainSceneState>(value: initialState)
    }
    
    private let bag = DisposeBag()
    
}
