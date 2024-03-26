//
//  FileManager+Extension.swift
//  Core
//
//  Created by 최준영 on 3/26/24.
//

import Foundation

struct ExtData: Codable {
    
    var urls: [ExtDataElement]
}

struct ExtDataElement: Codable {
    
    var url: String
    var isFetched: Bool
}

enum SaveExtDataError: Error {
    
    case directoryCreationError
    case fileCreationError
    case encodingError
    case decodingError
    case readingFileError
    case fileWritingError

}


public extension FileManager {
    
    static let sharedPath: URL = {
        
        guard let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.shortcap") else {
            fatalError()
        }
        
        return path
    }()
    
    func saveUrl(_ url: String) throws {
         
        // 중복 검사(논의 필요)
        
        // JSON파일이 존재하는 지 확인
        
        let filePath = Self.sharedPath.appending(path: "extension/urls.json")
        
        // 파일이 존재하지 않는 경우
        if !self.fileExists(atPath: filePath.path()) {
            
            // 폴더생성
            let directoryPath = Self.sharedPath.appending(path: "extension")
            
            try? self.createDirectory(at: directoryPath, withIntermediateDirectories: false)
            
            let extData = ExtData(urls: [
                ExtDataElement(
                    url: url,
                    isFetched: false
                )
            ])
            
            guard let encoded = try? JSONEncoder().encode(extData) else { throw SaveExtDataError.encodingError }
            
            self.createFile(atPath: filePath.path(), contents: encoded)
            
        } else {
            
            // 파일이 존재하는 경우
            guard let data: Data = try? Data(contentsOf: filePath) else { throw SaveExtDataError.readingFileError }
            
            guard var decoded = try? JSONDecoder().decode(ExtData.self, from: data) else { throw SaveExtDataError.decodingError }
            
            decoded.urls.append(
                ExtDataElement(
                    url: url,
                    isFetched: false
                )
            )
            
            guard let encoded = try? JSONEncoder().encode(decoded) else { throw SaveExtDataError.encodingError }
            
            guard (try? encoded.write(to: filePath)) != nil else { throw SaveExtDataError.fileWritingError }
        }
    }
}
