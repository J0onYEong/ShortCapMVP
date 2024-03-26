//
//  ShareViewController.swift
//  ShareExtensionForShortCap
//
//  Created by 최준영 on 3/4/24.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers
import Core

struct SwiftUIView: View {
    
    let text: String
    
    @State var showAlert = false
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Button("닫기", action: closeShareView)
                
                Spacer()
                
                Button("업로드") {
                    
                    Task {
                        
                        do {
                            
                            try FileManager.default.saveUrl(text)
                        } catch {
                            
                            print(error)
                        }
                    }
                    
                    closeShareView()
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            Text(text)
            
            Spacer()
        }
        .alert("코어데이터 저장 에러 발생", isPresented: $showAlert) {
            
            Button("닫기") {
                
                closeShareView()
            }
            
        }
        
    }
    
    func closeShareView() {
        
        NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
    }
    
}

class MyShareExtensionController: UIViewController {

    override func viewDidLoad() {
        
        guard let extensionitem = extensionContext?.inputItems.first as? NSExtensionItem, let itemProvider = extensionitem.attachments?.first else {
            
            return closeShareWindow()
        }
        
        let identifiers = [
            UTType.text.identifier,
            UTType.url.identifier
        ]
        
        for identifier in identifiers {
            
            if itemProvider.hasItemConformingToTypeIdentifier(identifier) {
                
                itemProvider.loadItem(forTypeIdentifier: identifier, options: nil) { (content, error) in
                    
                    if error == nil { return }
                    
                    var urlString: String?
                    
                    if identifier == UTType.url.identifier {
                        
                        urlString = (content as? URL)?.absoluteString
                    } else {
                        
                        urlString = content as? String
                    }
                    
                    if let urlString, ContentValidator.checkIsValidUrl(str: urlString) {
                        
                        OperationQueue.main.addOperation {
                            
                            self.addSwiftUIView(text: urlString)
                        }
                        
                    }
                    
                }
                
                break
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShareDataUpdated"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.closeShareWindow()
            }
        }
        
        // 옵저버 등록
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.closeShareWindow()
            }
        }
        
    }
    
    func addSwiftUIView(text: String) {
        
        let childVC = UIHostingController(rootView: SwiftUIView(text: text))
        
        self.addChild(childVC)
        
        self.view.addSubview(childVC.view)
        
        childVC.view.translatesAutoresizingMaskIntoConstraints = false
        childVC.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        childVC.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
        childVC.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        childVC.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
    }
    
    func closeShareWindow() {
        
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
}
