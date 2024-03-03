//
//  APIFetcherInterface.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

enum APIRequestError: Error {
    
    case statusCodeFailure(code: Int)
    case summaryFailed
    case decodingFailure
    case unknownError(description: String)
}

protocol APIFetcher {
    
    func requestSFSummary(sFUrl: String) async throws -> String
    
    func checkRequest(uuid: String, completion: @escaping (Result<SFModel, APIRequestError>) -> Void)
}
