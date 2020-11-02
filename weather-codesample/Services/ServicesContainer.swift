//
//  ServicesContainer.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import Foundation
import UIKit


final class ServicesContainer {
    lazy var networking: ApiController = { ApiController() }()
    lazy var location: LocationService = { LocationService() }()
}

// Network client
protocol Networkingable {
    var apiClient: ApiController { get }
}
extension Networkingable {
    var apiClient: ApiController  {
        return (UIApplication.shared.delegate as! AppDelegate).services.networking
     }
}

// Location service
protocol Locationable {
    var locationService: LocationService { get }
}
extension Locationable {
    var locationService: LocationService {
        return (UIApplication.shared.delegate as! AppDelegate).services.location
    }
}
 
