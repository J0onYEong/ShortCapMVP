//
//  Config.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/21/24.
//

import Foundation

enum Config {
    
    enum Network {
        
        static let base: String = {
            
            guard let path = Bundle.main.path(forResource: "Configs", ofType: "plist") else { fatalError() }
            
            guard let plist = NSDictionary(contentsOfFile: path) else { fatalError() }
            
            guard let baseUrl = plist["baseUrl"] as? String else { fatalError() }
            
            return baseUrl
        }()
    }
}
