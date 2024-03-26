//
//  File.swift
//  Core
//
//  Created by 최준영 on 3/26/24.
//

import Foundation

public struct ContentValidator {
    
    private init() { }
    
    static let instagramRegexStr = "((http|https):\\/\\/)*(www.)*instagram.com\\/reel\\/.*"
    static let youtubeRegexStr = "((http|https):\\/\\/)*(www.)*youtube.com\\/shorts\\/.*"
    
    public static func checkIsValidUrl(str: String) -> Bool {
        
        let patterns = [
            Self.instagramRegexStr,
            Self.youtubeRegexStr
        ]
        
        for pattern in patterns {
            
            let regex = try! NSRegularExpression(pattern: pattern)
            let range = NSRange(str.startIndex..., in: str)
            let matches = regex.matches(in: str, range: range)
            
            if let matchedStr = matches.first, matchedStr.range.length == str.count {
                
                return true
            }
        }
        
        return false
    }
}
