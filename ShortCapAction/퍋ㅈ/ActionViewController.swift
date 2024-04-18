import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import Core2
import Domain
import Data

enum ActionViewError: Error {
    
    case invalidStringForUrl
    case retrievingFailedWithUrl
    
    case matchedDataNotFound
}

class ActionViewModel {
    
    let useCase = SaveVideoCodeUseCase(
        summaryRepo: SummaryRepository(),
        videoRepo: VideoCodeRepository()
    )

    func saveData(urlStr: String) async throws {
        
        // 유효한 url인지 확인하기
        guard useCase.checkUrlFormIsValid(urlString: urlStr) else { throw  ActionViewError.invalidStringForUrl }
        
        // url로 부터 비디오 코드 획득
        do {
            let code = try await useCase.getVideoCodeFrom(urlString: urlStr).videoCode
            
            // 도출한 코드를 저장
            useCase.saveVideoCode(videoCode: code)
            
        } catch {
            print("비디오코드 획득 오류 \(error.localizedDescription)")
            
            throw ActionViewError.retrievingFailedWithUrl
        }
    }
}

class ActionViewController: UIViewController {
    
    let viewModel = ActionViewModel()
    
    let button: CloseButton = {
        
        let view = CloseButton()
    
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 24),
            button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            button.heightAnchor.constraint(equalToConstant: 64),
        ])
        
        button.addTarget(self, action: #selector(whenButtonPressed), for: .touchUpInside)
        
        button.loading()
        
        // 리소를 찾을 수 없을 시 화면을 드랍
        fetchUrl { [weak self] result in
            
            switch result {
            case .success(let urlString):
                
                print("✅ 추출된URL: \(urlString)")
                
                // 비디오 코드 확인
                Task {
                    
                    do {
                        
                        try await self?.viewModel.saveData(urlStr: urlString)
                        
                        // 작업 완료후 닫기 버튼
                        self?.button.stopLoading(isSuccess: true)
                        
                    } catch {
                        
                        print("‼️ 요약시작 오류 \(error)")
                        
                        self?.button.stopLoading(isSuccess: false)
                    }
                }
            case .failure(let failure):
                
                print("‼️ \(failure.localizedDescription)")
                
                self?.dropActivityView()
            }
        }
            
        
    }
    

    @objc
    func whenButtonPressed(_ sender: UIButton) {
        
        dropActivityView()
    }
    
    func dropActivityView() {
        
        self.extensionContext?.completeRequest(returningItems: nil)
    }
    
    func fetchUrl(completion: @escaping ((Result<String, ActionViewError>) -> Void)) {
        
        guard let item = (self.extensionContext?.inputItems as? [NSExtensionItem])?.first, let providers = item.attachments else {
            
            return completion(.failure(.matchedDataNotFound))
        }
        
        var checkFlag = false
        
        for provider in providers {
            
            // Instagram - webUrl, Youtube - text
            let idetifiers = [UTType.url.identifier, UTType.text.identifier]
            
            for id in idetifiers {
                
                if provider.hasItemConformingToTypeIdentifier(id) {
                    
                    checkFlag = true
                    
                    provider.loadItem(forTypeIdentifier: id, options: nil) { (string, error) in
                        
                        if error != nil {
                            
                            return completion(.failure(.matchedDataNotFound))
                        }
                        
                        var urlString: String?
                        
                        if id == UTType.url.identifier {
                            
                            urlString = (string as? URL)?.absoluteString
                        } else {
                            
                            urlString = string as? String
                        }
                        
                        if let urlString {
                            
                            completion(.success(urlString))
                        }
                    }
                }
            }
        }
        
        if !checkFlag {
            
            completion(.failure(.matchedDataNotFound))
        }
    }
}


