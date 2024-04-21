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
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \(error.userInfo)")
            }
            
            print("✅ 영구 저장소 로딩 성공")
        }
        return container
    }()

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




// MARK: - 파일시스템(이전 버전, 테스트 안됨)
class FileSystemVideoCodeStorage: VideoCodeStorage {

    let manager = FileManager.default
    
    let fileName = "videoCodes.json"
    let directories = ["extension"]
    
    public var absolutePath: String {
        
        directories.reduce("", { $0 + "/\($1)" }) + "/\(fileName)"
    }
    
    let shardPath = FileManager.sharedPath
    
    public init() { }
    
    func save(videoCodeDTO: VideoCodeDTO, completion: @escaping (Result<VideoCodeDTO, Error>) -> Void) {
        
        let filePath = shardPath.appending(path: absolutePath)
        
        // 디렉토리가 없는 경우 디렉토리 생성
        if !manager.fileExists(atPath: filePath.path()) {
            
            // 폴더생성
            let directoryPath = shardPath.appending(path: directories.last ?? "")
            
            try! manager.createDirectory(at: directoryPath, withIntermediateDirectories: false)
            
        }
        
        // 파일존재여부 확인
        if let data: Data = try? Data(contentsOf: filePath),
           let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let codes = decoded["codes"] as? [String] {
            
            var newCodes = codes
            
            newCodes.append(videoCodeDTO.code)
            
            let jsonObject: [String: Any] = [
                "codes" : newCodes
            ]
            
            guard let encoded = try? JSONSerialization.data(withJSONObject: jsonObject) else { fatalError() }
            
            try! encoded.write(to: filePath)
            
        } else {
            
            let jsonObject: [String: Any] = [
                "codes" : [videoCodeDTO.code]
            ]
            
            guard let encoded = try? JSONSerialization.data(withJSONObject: jsonObject) else { fatalError() }
            
            manager.createFile(atPath: filePath.path(), contents: encoded)
        }
        
        completion(.success(videoCodeDTO))
    }
    
    public func getResponse(completion: @escaping (Result<[VideoCodeDTO], Error>) -> Void) {
        
        let filePath = shardPath.appending(path: absolutePath)
        
        if manager.fileExists(atPath: filePath.path()) {
            
            guard let data: Data = try? Data(contentsOf: filePath) else { fatalError() }
            
            if data.isEmpty { return completion(.success([])) }
            
            guard let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let codes = decoded["codes"] as? [String] else { fatalError() }
            
            let dtos = codes.map { VideoCodeDTO(code: $0) }
            
            // 파일 내용 추출후 파일을 비운다.
            if let fileHandle = try? FileHandle(forWritingTo: URL(fileURLWithPath: filePath.path())) {
                
                // 파일 내용을 비우기
                fileHandle.truncateFile(atOffset: 0)
                
                // 파일 닫기
                fileHandle.closeFile()
            }
            
            completion(.success(dtos))
            
        } else {
            
            completion(.success([]))
        }
    }
}
