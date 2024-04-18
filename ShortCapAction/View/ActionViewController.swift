import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    
    let viewModel = ActionViewModel()
    
    let button: CloseButton = {
        
        let view = CloseButton()
    
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let notificationLabel: UILabel = {
       
        let view = UILabel()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        
        view.shadowColor = .gray
        view.shadowOffset = .init(width: 0, height: 1)
        
        view.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        return view
    }()
    
    let notificationLabelImage: UIImageView = {
       
        let view = UIImageView()
        
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = .init(width: 0, height: 1)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        view.addSubview(notificationLabel)
        view.addSubview(notificationLabelImage)
        
        NSLayoutConstraint.activate([
            
            notificationLabelImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            notificationLabelImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
            notificationLabelImage.widthAnchor.constraint(equalToConstant: 48),
            
            notificationLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            notificationLabel.leadingAnchor.constraint(equalTo: self.notificationLabelImage.trailingAnchor, constant: 5),
            notificationLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),
            
            button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -56),
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
                        
                        self?.whenComplete(isSuccess: true)
                        
                    } catch {
                        
                        print("‼️ 요약시작 오류 \(error)")
                        
                        self?.whenComplete(isSuccess: false)
                    }
                }
            case .failure(let failure):
                
                print("‼️ \(failure.localizedDescription)")
                
                self?.dropActivityView()
            }
        }
    }
    
    func whenComplete(isSuccess: Bool) {
        
        UIView.animate(withDuration: 0.5) {
            
            self.button.stopLoading(isSuccess: isSuccess)
            
            if isSuccess {
                
                self.notificationLabel.text = "저장 성공!"
                self.notificationLabelImage.image = .init(systemName: "checkmark.diamond.fill")
                self.notificationLabelImage.tintColor = .green
                
            } else {
                
                self.notificationLabel.text = "저장 실패"
                self.notificationLabelImage.image = .init(systemName: "xmark.diamond.fill")
                self.notificationLabelImage.tintColor = .red
                
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


