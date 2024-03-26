//
//  TestSFFetcher.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation
import CoreData

class TestPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {

        return super.defaultDirectoryURL()
            .appendingPathComponent("ShortCap")
            .appendingPathComponent("Test")
            .appendingPathComponent("Forms")
    }
}

class TestSFFetcher: SFFetcher {
    
    func moveFileDataToCoreData() {
        
    }
    
    static let modelName = "ShareShortFormModel"
    
    let container: TestPersistentContainer
    
    var context: NSManagedObjectContext { container.viewContext }
    
    init() {
        
        let model = Self.model(for: Self.modelName, bundle: .main)
        
        self.container = .init(name: "TestContainer", managedObjectModel: model)
        
        self.container.loadPersistentStores { (desc, error) in
            
            if let _ = error {
                
                fatalError("❌ 영구 저장소 로딩 실패")
            }
            
            print("✅ 영구 저장소 로딩 성공")
        }
        
        insertDummyData()
    }
    
    func insertDummyData() {
        
        let request = SharedShortForm.fetchRequest()
        
        let fetchResult = try! context.fetch(request)
        
        fetchResult.forEach {
            context.delete($0)
        }
        
        dummyData.forEach { model in
            
            let ssf = SharedShortForm(context: context)
            
            ssf.url = model.entity.url!
            
            if model.isFetched {
                let ssfData = SSFData(context: context)
                
                ssfData.title = model.entity.title
                
                ssf.sfData = ssfData
            }
        }
        
        try? context.save()
    }
    
    
    static func model(for name: String, bundle: Bundle) -> NSManagedObjectModel {
        
        let modelURL = bundle.url(forResource: name, withExtension: ".momd")!
        
        let model = NSManagedObjectModel(contentsOf: modelURL)!

        return model
    }
    
    let dummyData: [SummaryContentModel] = [
        
        SummaryContentModel(
            entity: SummaryResultData(
                title: "유튜브 쇼츠 더미1",
                description: "더미객체1의 설명입니다.",
                keywords: ["키워드1", "키워드2", "키워드3"],
                url: "https://youtube.com/shorts/e5jsSi_aKmM?si=vRUkRp2utJV00Vbt",
                summary: "더미객체1의 요약입니다.",
                address: "더미객체1의 주소입니다.",
                createdAt: "2024-03-03T20:00:00.000"
            ),
            
            isFetched: true
        ),
        
        SummaryContentModel(
            entity: SummaryResultData(
                title: "인스타 릴스 더미2",
                description: "더미객체2의 설명입니다.",
                keywords: ["키워드1", "키워드2", "키워드3"],
                url: "https://www.instagram.com/reel/C3bm6JNPwbW/?utm_source=ig_web_copy_link",
                summary: "더미객체2의 요약입니다.",
                address: "더미객체2의 주소입니다.",
                createdAt: "2024-03-03T20:00:00.000"
            ),
            
            isFetched: true
        ),
        
        SummaryContentModel(
            entity: SummaryResultData(
                title: nil,
                description: nil,
                keywords: [],
                url: "https://youtube.com/shorts/BjjtDjkSlRo?si=Mt_4Sh6L8_tJu-z3",
                summary: nil,
                address: nil,
                createdAt: nil
            ),
            
            isFetched: false
        ),
        
//        SFModel(
//            uuid: "4",
//            title: nil,
//            description: nil,
//            keywords: nil,
//            url: "https://www.instagram.com/reel/C1odCzdSpNr/?utm_source=ig_web_copy_link",
//            summary: nil,
//            address: nil,
//            createdAt: nil,
//            isFetched: false
//        )
    ]
    
    func getSummaryContentModels(completion: @escaping (Result<SummaryContentListModel, SFFetcherError>) -> Void) {
        
        let fetchRequest = SharedShortForm.fetchRequest()
        
        do {
            
            let shortForms = try context.fetch(fetchRequest)
            
            print(shortForms.count)
            
            let summayContentModels = shortForms.map { form in
                    
                if let fetchedData = form.sfData {
                    
                    var keyWords: [String] = []
                    
                    if let localKeyWords = fetchedData.keyWords {
                        
                        Set(_immutableCocoaSet: localKeyWords).forEach { (fk: FormKeywords) in
                            if let str = fk.keyword {
                                keyWords.append(str)
                            }
                        }
                    }
                    
                    let entity = SummaryResultData (
                        title: fetchedData.title,
                        description: fetchedData.sfDescription,
                        keywords: keyWords,
                        url: form.url,
                        summary: fetchedData.summary,
                        address: fetchedData.address,
                        createdAt: fetchedData.createdAt
                    )
                    
                    return SummaryContentModel(entity: entity, isFetched: true)
                    
                } else {
                    
                    let entity = SummaryResultData(url: form.url)
                    
                    return SummaryContentModel(entity: entity)
                }
            }
            
            completion(.success(summayContentModels))
            
        } catch {
            
            completion(.failure(.errorInFetchingProcess))
        }
        
    }
    
    func updateLocalSummaryContentWith(model: SummaryContentModel) {
        
        guard let idForLocalData = model.entity.url else {
            
            print("일치하는 데이터를 찾을 수 없습니다.")
            return;
        }
        
        container.performBackgroundTask { backContext in
            
            let request = SharedShortForm.fetchRequest()
            
            let ssfs = try! backContext.fetch(request)
            
            if let target = ssfs.first(where: { $0.url == idForLocalData }) {
                
                // 로컬에 이미존재하는 SharedShortForm에 요약된 데이터를 주입
                let sfData = SSFData(context: backContext)
                
                let entity = model.entity
            
                sfData.title = entity.title
                sfData.sfDescription = entity.description
                sfData.summary = entity.summary
                sfData.address = entity.address
                sfData.createdAt = entity.createdAt
                
                entity.keywords.forEach { word in
                    
                    let object = FormKeywords(context: backContext)
                    
                    object.keyword = word
                    
                    sfData.addToKeyWords(object)
                }
                
                target.sfData = sfData
                
                try? backContext.save()
            }
        }
    }
}
