//
//  SummaryContentListViewModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

class SummaryContentListViewModel {
    
    var model: SummaryContentListModel = [] {
        
        didSet {
            onModelIsModified?()
        }
    }
    
    var sfFetcher: SFFetcher
    
    var apiService: SummaryService
    
    var onModelIsModified: (() -> Void)?
    
    init(sfFetcher: SFFetcher, apiService: SummaryService) {
        
        self.sfFetcher = sfFetcher
        self.apiService = apiService
    }
    
    func fetchLocalData() {
        
        sfFetcher.getSummaryContentModels { result in
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
}

extension SummaryContentListViewModel {
    
    /// List뷰모델의 모델배열로 부터 독립적인 SummaryContentViewModel을 생성한다.
    func makeViewModelFromList(index: Int) -> SummaryContentViewModel {
        
        let model = model[index]
        
        let viewModel = SummaryContentViewModel(
            model: model,
            apiService: apiService,
            sfFetcher: sfFetcher
        )
        
        return viewModel
    }
}
