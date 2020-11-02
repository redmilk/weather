//
//  CLLocationManager+Rx.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation

extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}




class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>,
                                        DelegateProxyType,
                                        CLLocationManagerDelegate {
    
    weak public private(set) var locationManager: CLLocationManager?
    
    public init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
    }
}





public extension Reactive where Base: CLLocationManager {
    
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { parameters in
                return parameters[1] as! [CLLocation]
        }
    }
    
}
