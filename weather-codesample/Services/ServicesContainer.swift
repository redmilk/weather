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

protocol Networking {
    var apiClient: ApiController { get }
}

extension Networking {
    var apiClient: ApiController  {
        return (UIApplication.shared.delegate as! AppDelegate).services.networking
     }
}
 
