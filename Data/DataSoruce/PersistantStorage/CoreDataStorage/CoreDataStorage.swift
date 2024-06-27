import Foundation
import CoreData

enum CoreDataStorageError: Error {
    case readError(Error)
    case saveError(Error)
    case deleteError(Error)
}

public final class CoreDataStorage {

    public static let shared = CoreDataStorage()
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        
        let bundle = Bundle(for: type(of: self))
        
        // 모델파일이름
        let modelFileName = "CoreDataModel"
        
        guard let modelURL = bundle.url(forResource: modelFileName, withExtension: ".momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            
            fatalError("모델파일을 찾을 수 없음")
        }
        
        let container = NSPersistentContainer(name: "CoreDataStorage", managedObjectModel: model)
        
        // 앱그룹 공유저장소를 저장소의 위치로 지정
        if let appGroupIdentifier = Bundle.main.infoDictionary?["App Group"] as? String {
            
            let storeURL = URL.storeURL(for: appGroupIdentifier, databaseName: "DataModel")
            
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
            
            printIfDebug("✅ \(appGroupIdentifier)저장소")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \(error.userInfo)")
            }
            
            printIfDebug("✅ 영구 저장소 로딩 성공")
        }
        return container
    }()

    public var viewContext: NSManagedObjectContext {
        
        persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
