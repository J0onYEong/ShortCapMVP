//
//  SFFetchInterFace.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

enum SFFetcherError: Error {
    
    case errorInFetchingProcess
}

protocol SFFetcher {
    
    func getSFModels(completion: @escaping (Result<[SFModel], SFFetcherError>) -> Void)
    
    func updateLocalData(model: SFModel)
}
