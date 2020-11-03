//
//  ServicesContainer.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import UIKit

fileprivate let services = ServicesContainer()

final class ServicesContainer {
    lazy var networking: ApiController = { ApiController() }()
    lazy var reachability: Reachability = { Reachability() }()
    lazy var location: LocationService = { LocationService() }()
    lazy var stateStore: StateStore = { StateStore() }()
}

// Actions implement these protocols to get needed functionality
// And only state store is implemented by VC for fetching actual state

/// - Storage of application scene states
protocol StateStoreSupporting { }

extension StateStoreSupporting {
    var store: StateStore {
        return services.stateStore
    }
}

/// - Network client
protocol NetworkSupporting {
    var apiClient: ApiController { get }
}
extension NetworkSupporting {
    var apiClient: ApiController  {
        return services.networking
     }
}

/// - Location service
protocol LocationSupporting {
    var locationService: LocationService { get }
}
extension LocationSupporting {
    var locationService: LocationService {
        return services.location
    }
}

/// - Reachability
protocol ReachabilitySupporting {
    var reachability: Reachability { get }
}
extension ReachabilitySupporting {
    var reachability: Reachability {
        return services.reachability
    }
}

 
