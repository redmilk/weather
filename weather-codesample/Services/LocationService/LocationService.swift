//
//  LocationService.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import CoreLocation
import RxSwift


final class LocationService {
    
    enum LocationAccuracy {
        case bestForNavigation
        case best
        case nearestTenMeters
        case hundredMeters
        case kilometer
        case threeKilometers
    }
    
    var currentLocation: Observable<CLLocation> {
        return locationManager.rx.didUpdateLocations
            .map { locations in locations[0] }
            .filter { location in
                return location.horizontalAccuracy < kCLLocationAccuracyHundredMeters
            }
    }
    
    var isLocationPermissionGranted: Observable<Bool> {
        return locationManager.rx.isLocationPermissionGranted
    }
    
    func setAccuracy(_ accuracy: LocationAccuracy) {
        switch accuracy {
        case .bestForNavigation:
            self.accuracy = kCLLocationAccuracyBestForNavigation
        case .best:
            self.accuracy = kCLLocationAccuracyBest
        case .nearestTenMeters:
            self.accuracy = kCLLocationAccuracyNearestTenMeters
        case .hundredMeters:
            self.accuracy = kCLLocationAccuracyHundredMeters
        case .kilometer:
            self.accuracy = kCLLocationAccuracyKilometer
        case .threeKilometers:
            self.accuracy = kCLLocationAccuracyThreeKilometers
        }
    }
    
    func requestPermission() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    init(accuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters) {
        self.accuracy = accuracy
    }
    
    private let locationManager = CLLocationManager()
    private var accuracy: CLLocationAccuracy
    private let bag = DisposeBag()
    
}