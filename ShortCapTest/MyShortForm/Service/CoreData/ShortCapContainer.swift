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

public extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

public class ShortCapContainer {
    
    static let modelName = "ShareShortFormModel"
    
    let container: ShortCapPersistentContainer
    
    var context: NSManagedObjectContext { container.viewContext }
    
    public init() {
        
        let model = Self.model(for: Self.modelName, bundle: .main)
        
        let storeURL = URL.storeURL(for: "group.shortcap", databaseName: "DataModel")
         
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        
        self.container = .init(name: "ShortCapContainer", managedObjectModel: model)
        
        container.persistentStoreDescriptions = [storeDescription]
        
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
            
            print(shortForms.count)
            
            let sFModelArray = shortForms.map { form in
                    
                if let fetchedData = form.sfData {
                    
                    var keyWords: [String] = []
                    
                    if let localKeyWords = fetchedData.keyWords {
                        
                        Set(_immutableCocoaSet: localKeyWords).forEach { (fk: FormKeywords) in
                            if let str = fk.keyword {
                                keyWords.append(str)
                            }
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

public extension ShortCapContainer {
    
    func saveUrlFromSharedExtension(url: String) {
        
        let ssf = SharedShortForm(context: context)
        
        ssf.url = url
        
        try? context.save()
    }
}
