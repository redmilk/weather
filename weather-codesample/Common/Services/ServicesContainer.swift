//
//  ServicesContainer.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 02.11.2020.
//

import UIKit

fileprivate let services = ServicesContainer()

final class ServicesContainer {
    lazy var baseApiClient: ApiClient = { ApiClient() }()
    lazy var weatherApi: WeatherApi = { WeatherApi(requestable: ApiClient()) }()
    lazy var reachability: Reachability = { Reachability() }()
    lazy var location: LocationService = { LocationService() }()
    lazy var stateStore: StateStore = { StateStore() }()
    lazy var formatting: FormattingService = { FormattingService() }()
}

// Actions implement these protocols to get needed functionality

/// - Storage of application scene states
protocol StateStoreSupporting { }
extension StateStoreSupporting {
    var store: StateStore {
        return services.stateStore
    }
}

/// - Location service
protocol LocationSupporting { }
extension LocationSupporting {
    var locationService: LocationService {
        return services.location
    }
}

/// - Reachability
protocol ReachabilitySupporting { }
extension ReachabilitySupporting {
    var reachability: Reachability {
        return services.reachability
    }
}

/// - Common api client
protocol NetworkSupporting { }
extension NetworkSupporting {
    var apiClient: ApiClient  {
        return services.baseApiClient
     }
}

/// - Weather API
protocol WeatherApiSupporting { }
extension WeatherApiSupporting {
    var weatherApi: WeatherApi {
        return services.weatherApi
    }
}

/// - Formatting
protocol FormattingSupporting { }
extension FormattingSupporting {
    var formatting: FormattingService {
        return services.formatting
    }
}

 
