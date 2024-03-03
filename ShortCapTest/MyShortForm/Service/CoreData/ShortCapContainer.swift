//
//  ShortCapContainer.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/4/24.
//

import Foundation
import CoreData

class ShortCapPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {

        return super.defaultDirectoryURL()
            .appendingPathComponent("ShortCap")
            .appendingPathComponent("Local")
            .appendingPathComponent("Forms")
    }
}

class ShortCapContainer {
    
    static let modelName = "ShareShortFormModel"
    
    let container: ShortCapPersistentContainer
    
    var context: NSManagedObjectContext { container.viewContext }
    
    init() {
        
        let model = Self.model(for: Self.modelName, bundle: .main)
        
        self.container = .init(name: "ShortCapContainer", managedObjectModel: model)
        
        self.container.loadPersistentStores { (desc, error) in
            
            if let _ = error {
                
                fatalError("❌ 영구 저장소 로딩 실패")
            }
            
            print("✅ 영구 저장소 로딩 성공")
        }
    }
    
    
    static func model(for name: String, bundle: Bundle) -> NSManagedObjectModel {
        
        let modelURL = bundle.url(forResource: name, withExtension: ".momd")!
        
        let model = NSManagedObjectModel(contentsOf: modelURL)!

        return model
    }
}

extension ShortCapContainer: SFFetcher {
    
    func getSFModels(completion: @escaping (Result<[SFModel], SFFetcherError>) -> Void) {
        
        let fetchRequest = SharedShortForm.fetchRequest()
        
        do {
            
            let shortForms = try context.fetch(fetchRequest)
            
            let sFModelArray = shortForms.map { form in
                
                if let fetchedData = form.sfData {
                    
                    var keyWords: [String] = []
                    
                    if let localKeyWords = fetchedData.keyWords {
                        
                        localKeyWords.allObjects.forEach { str in
                            keyWords.append(str as! String)
                        }
                    }
                    
                    return SFModel(
                        uuid: fetchedData.uuid,
                        title: fetchedData.title,
                        description: fetchedData.sfDescription,
                        keywords: keyWords,
                        url: form.url,
                        summary: fetchedData.summary,
                        address: fetchedData.address,
                        createdAt: fetchedData.createdAt,
                        isFetched: true
                    )
                    
                } else {
                    
                    return SFModel(url: form.url)
                }
            }
            
            completion(.success(sFModelArray))
            
        } catch {
            
            completion(.failure(.errorInFetchingProcess))
        }
        
    }
    
    func updateLocalData(model: SFModel) {
        
        let url = model.url!
        
        container.performBackgroundTask { backContext in
            
            let request = SharedShortForm.fetchRequest()
            
            let ssfs = try! backContext.fetch(request)
            
            if let target = ssfs.first(where: { $0.url == url }) {
                
                let sfData = SSFData(context: backContext)
                
                sfData.uuid = model.uuid
                sfData.title = model.title
                sfData.sfDescription = model.description
                sfData.summary = model.summary
                sfData.address = model.address
                sfData.createdAt = model.createdAt
                
                if let keywords = model.keywords {
                    
                    keywords.forEach { word in
                        
                        let object = FormKeywords(context: backContext)
                        
                        object.keyword = word
                        
                        sfData.addToKeyWords(object)
                    }
                }
                
                target.sfData = sfData
                
                try? backContext.save()
            }
        }
    }
}
