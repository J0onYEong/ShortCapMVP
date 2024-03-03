//
//  SFListViewModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

class SFListViewModel {
    
    var model: [SFModel] = [] {
        
        didSet {
            onModelIsModified?()
        }
    }
    
    var sfFetcher: SFFetcher
    
    var apiFetcher: APIFetcher
    
    var onModelIsModified: (() -> Void)?
    
    init(sfFetcher: SFFetcher, apiFetcher: APIFetcher) {
        
        self.sfFetcher = sfFetcher
        self.apiFetcher = apiFetcher
    }
    
    func fetchCellData() {
        
        sfFetcher.getSFModels { result in
            switch result {
            case .success(let success):
                
                DispatchQueue.main.async {
                    
                    self.model = success
                }
            case .failure(let failure):
                
                print(failure)
            }
        }
    }
    
    func generateSFViewModel(index: Int) -> SFViewModel {
        
        let model = model[index]
        
        let viewModel = SFViewModel(
            model: model,
            apiFetcher: apiFetcher,
            sfFetcher: sfFetcher
        )
        
        return viewModel
    }
}
