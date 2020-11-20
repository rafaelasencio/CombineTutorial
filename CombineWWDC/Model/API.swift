//
//  API.swift
//  CombineWWDC
//
//  Created by RafaelAsencio on 20/11/2020.
//

import Foundation

enum NetworkErrors:Error {
    case BadContent
}



struct API {
    
    enum Endpoints {
        static let base = "https://jsonplaceholder.typicode.com/"
        
        case users
        
        var stringValue: String {
            switch self {
            case .users: return Endpoints.base + "users"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
}
