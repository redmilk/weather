//
//  ApplicationErrors.swift
//  weather-codesample
//
//  Created by Danyl Timofeyev on 04.11.2020.
//

import Foundation

enum ApplicationErrors {
    
    enum ApiClient {
        case cityNotFound
        case invalidToken
        case serverError
    }
    
    enum Location {
        case noPermission
    }
    
    enum Network {
        case noConnection
    }
    
}
