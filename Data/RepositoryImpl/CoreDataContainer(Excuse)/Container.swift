import Foundation
import CoreData
import RxCocoa
import Core
import Domain


public class ShortCapPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {

        return super.defaultDirectoryURL()
            .appendingPathComponent("ShortCap")
            .appendingPathComponent("Local")
            .appendingPathComponent("Forms")
    }
}

public class ShortCapContainer {
    
    private static let modelName = "ShareShortFormModel"
    
    private static let identifier = "choijunyeong.ShortCapNetwork"
    
    private let container: ShortCapPersistentContainer
    
    private var context: NSManagedObjectContext { container.viewContext }
    
    public static let shared = ShortCapContainer()
    
    private init() {
        
        guard let moduleBundle = Bundle(identifier: Self.identifier) else { fatalError() }
        
        let model = Self.model(for: Self.modelName, bundle: moduleBundle)
        
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

public extension ShortCapContainer {
 
    func getSummaryContent() -> [SummaryResultEntity] {
        
        let fetchRequest = SummaryLD.fetchRequest()
        
        do {
            
            let localSavedData = try context.fetch(fetchRequest)
            
            print("코어데이터 저장 숏폼수: \(localSavedData.count)")
            
            let entities = localSavedData.map { item in
                
                var keywords: [String] = []
                
                if let keywordsStr = item.keywords {
                    
                    keywords = keywordsStr.split(separator: ",").map({ String($0) })
                }
                
                return SummaryResultEntity(
                    title: item.title ?? "",
                    description: item.des ?? "",
                    keywords: keywords,
                    url: item.url ?? "",
                    summary: item.summary ?? "",
                    address: item.address ?? "",
                    createdAt: item.createdAt ?? "",
                    platform: item.platform ?? "",
                    mainCategory: item.mainCategory ?? "",
                    videoCode: item.videoCode ?? "",
                    isFetched: item.isFetched
                )
            }
            
            return entities
            
        } catch {
            
            fatalError()
        }
    }
    
    func updateSummaryContent(entities: [SummaryResultEntity]) {
        
        let fetchRequest = SummaryLD.fetchRequest()
        
        let localSavedData = try! context.fetch(fetchRequest)
        
        entities.forEach { item in
            
            localSavedData.forEach { object in
                
                if object.videoCode == item.videoCode {
                    
                    object.title = item.title
                    object.des = item.description
                    object.keywords = item.keywords.reduce("", { $0 + ",\($1)" })
                    object.url = item.url
                    object.summary = item.summary
                    object.address = item.address
                    object.createdAt = item.createdAt
                    object.platform = item.platform
                    object.mainCategory = item.mainCategory
                    object.videoCode = item.videoCode
                    object.isFetched = true
                }
            }
        }
        
        try? context.save()
    }
    
    func saveSummaryContent(entities: [SummaryResultEntity]) {
        
        entities.forEach { item in
            
            let object = SummaryLD(context: context)
            
            object.title = item.title
            object.des = item.description
            object.keywords = item.keywords.reduce("", { $0 + ",\($1)" })
            object.url = item.url
            object.summary = item.summary
            object.address = item.address
            object.createdAt = item.createdAt
            object.platform = item.platform
            object.mainCategory = item.mainCategory
            object.videoCode = item.videoCode
        }
        
        try? context.save()
    }
}
