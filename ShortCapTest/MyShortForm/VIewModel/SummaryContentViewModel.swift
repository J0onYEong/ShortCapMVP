//
//  SFViewModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation
import Combine

class SummaryContentViewModel {
    
    var model: SummaryContentModel {
        
        didSet {
            
            fetchCompletion?()
        }
    }
    
    var fetchCompletion: (() -> Void)?
    
    var apiService: SummaryService
    
    var sfFetcher: SFFetcher
    
    var isFetched: Bool {
        
        // 모델값이 갱신되고 선택되면 자동갱신
        model.isFetched
    }
    
    init(model: SummaryContentModel, apiService: SummaryService, sfFetcher: SFFetcher) {
        self.model = model
        self.apiService = apiService
        self.sfFetcher = sfFetcher
    }
    
    var title: String {
        model.entity.title ?? "로딩중 ..."
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    public func startFetching() {
        
        if !isFetched {
            
            if let videoUrl = model.entity.url {
                
                apiService.initiateSummary(videoUrl: videoUrl)
                    .sink { self.onConnectionFinished($0, "요약시작 실패") } receiveValue: { initialEntity in
                        
                        guard let videoId = initialEntity.data?.videoCode else { fatalError() }
                        
                        // 반복확인 시작
                        self.checkStatusReapeadly(videoId: videoId)
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    private func checkStatusReapeadly(videoId: String) {
        
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] timer in
            
            if let vm = self {
                
                vm.apiService.getSummaryStatus(videoId: videoId)
                    .sink { self?.onConnectionFinished($0, "상태가져오기 실패") } receiveValue: { statusEntity in
                        
                        guard let status = statusEntity.data?.status else { fatalError() }
                        
                        if status != "PROCESSING" {
                            
                            timer.invalidate()
                            
                            guard let pk = statusEntity.data?.videoPk else { fatalError() }
                            
                            self?.whenProcessingFinished(pk: String(pk))
                            
                        } else {
                            
                            print("⌛️처리중")
                        }
                    }
                    .store(in: &vm.cancellables)
                
            }
        }
    }
    
    private func whenProcessingFinished(pk: String) {
        
        cancellables.removeAll()
        
        getSummaryResult(pk)
        
    }
    
    private func getSummaryResult(_ pk: String) {
        
        apiService.getSummaryResult(videoPk: pk)
            .receive(on: DispatchQueue.main)
            .sink { self.onConnectionFinished($0, "결과 가져오기 실패") } receiveValue: { resultEntity in
                
                print("✅ 요약 성공")
                
                guard let data = resultEntity.data else { fatalError() }
                
                self.model = SummaryContentModel(entity: data, isFetched: true)
                
                // 요약한 정보를 영구저장소에 저장
                self.sfFetcher.updateLocalSummaryContentWith(model: self.model)
            }
            .store(in: &cancellables)
    }
    
    private func onConnectionFinished(_ result: Subscribers.Completion<Error>, _ description: String) {
        
        switch result {
        case .finished:
            return;
        case .failure(let error):
            print("❌ \(description)", error)
        }
    }
}
