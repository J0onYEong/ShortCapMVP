//
//  SFFetchInterFace.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

protocol SFFetcher {
    
    func getSFModels(completion: @escaping (Result<[SFModel], Error>) -> Void)
}
