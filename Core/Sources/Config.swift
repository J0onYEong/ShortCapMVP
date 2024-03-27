//
//  Config.swift
//  Core
//
//  Created by 최준영 on 3/26/24.
//

import Foundation

public enum Config {
    
    public enum Network {
        
        public static let base: String = {
            
            guard let baseUrl = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else { fatalError() }
            
            print("✅ baseUrl이 로드되었습빈다!")
            
            return baseUrl
        }()
    }
}
