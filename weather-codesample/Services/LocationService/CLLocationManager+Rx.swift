//
//  CLLocationManager+Rx.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

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
        return delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { parameters in
                parameters[1] as! [CLLocation]
            }
    }
    
    var isLocationPermissionGranted: Observable<Bool> {
        return delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFailWithError:)))
            .map { parameters in
                let error = (parameters[1] as? CLError)
                print("📡📡📡 🟥")
                if error!.errorCode == 1 {
                    throw ApplicationErrors.Location.noPermission
                }
                return !(error!.errorCode == 1)
            }
    }
    
}
