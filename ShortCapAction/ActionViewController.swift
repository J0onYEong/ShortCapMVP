//
//  ActionViewController.swift
//  ShortCapAction
//
//  Created by 최준영 on 3/25/24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import Core

class ActionViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var urlLabel: UILabel!
    
    @IBOutlet weak var exitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUISetUp()

        checkInput()
    }
    
    func initialUISetUp() {
        
        doneButton.setTitle("완료", for: .normal)
        doneButton.addTarget(self, action: #selector(whenDonePressed), for: .touchUpInside)
        doneButton.alpha = 0.0
        
        exitButton.setTitle("나가기", for: .normal)
        exitButton.addTarget(self, action: #selector(whenDonePressed), for: .touchUpInside)
        
        urlLabel.text = "지원하지 않는 형식이에요!"
    }
    
    var resultUrlString: String?
    
    func checkInput() {
        
        guard let item = (self.extensionContext?.inputItems as? [NSExtensionItem])?.first, let providers = item.attachments else {
            
            return
        }
        
        for provider in providers {
            
            // Instagram - webUrl, Youtube - text
            let idetifiers = [UTType.url.identifier, UTType.text.identifier]
            
            for id in idetifiers {
                
                if provider.hasItemConformingToTypeIdentifier(id) {
                    
                    provider.loadItem(forTypeIdentifier: id, options: nil) { (string, error) in
                        
                        var urlString: String?
                        
                        if id == UTType.url.identifier {
                            
                            urlString = (string as? URL)?.absoluteString
                        } else {
                            
                            urlString = string as? String
                        }
                        
                        if let urlString, ContentValidator.checkIsValidUrl(str: urlString) {
                            
                            OperationQueue.main.addOperation {
                                
                                // 성공한 경우
                                self.onValidURL()
                                
                                self.urlLabel.text = urlString
                                
                                self.resultUrlString = urlString
                            }
                        }
                    }
                    break
                }
            }
        }
    }
    
    func onValidURL() {
        exitButton.alpha = 0.0
        doneButton.alpha = 1.0
    }
    
    @objc
    func whenDonePressed(_ sender: UIButton) {
        
        if sender.title(for: .normal) == "완료" {
            
            do {
                
                if let resultUrlString {
                    
                    try FileManager.default.saveUrl(resultUrlString)
                }
                
            } catch {
                
                print(error)
            }
        }
        
        self.extensionContext?.completeRequest(returningItems: nil)
    }
}


