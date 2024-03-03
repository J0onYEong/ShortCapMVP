//
//  ShareViewController.swift
//  ShareExtensionForShortCap
//
//  Created by 최준영 on 3/4/24.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

struct SwiftUIView: View {
    
    @State var text: String
    
    @State var showAlert = false
    
    let container = ShortCapContainer()
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Button("닫기", action: closeShareView)
                
                Spacer()
                
                Button("업로드") {
                    
                    Task {
                        
                        container.saveUrlFromSharedExtension(url: text)
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
        
        
        
        var textToSend: String = "\(extensionitem.attachments?.count) 지정된 식별자를 만족하지 않음"
        
        let identifiers = [
            UTType.text.identifier,
            UTType.url.identifier
        ]
        
        var isMatched = false
        
        for identifier in identifiers {
            
            
            
            if itemProvider.hasItemConformingToTypeIdentifier(identifier) {
                
                isMatched = true
                
                itemProvider.loadItem(forTypeIdentifier: identifier, options: nil) { (providedText, error) in
                    
                    if error != nil {
                        
                        textToSend = "에러발생"
                    } else if let text = providedText as? String {
                        
                        textToSend = text
                        
                    }else if let url = providedText as? URL {
                        
                        textToSend = url.absoluteString
                    }
                    else {
                        
                        textToSend = "데이터 타입 변환 실패"
                    }
                    
                    DispatchQueue.main.async {
                        self.addSwiftUIView(text: textToSend)
                    }
                    
                }
                
            }
            
        }
        
        // 매치된 타입이 없는 경우
        if !isMatched {
            
            if !itemProvider.registeredContentTypes.isEmpty {
             
                textToSend += "UTI: \(itemProvider.registeredContentTypes.first!)"
            }

            DispatchQueue.main.async {
                self.addSwiftUIView(text: textToSend)
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
