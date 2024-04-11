import Foundation
import Domain

public final class VideoCodeRepository: VideoCodeRepositoryInterface {

    let manager = FileManager.default
    
    let fileName = "videoCodes.json"
    let directories = ["extension"]
    
    public var absolutePath: String {
        
        directories.reduce("", { $0 + "/\($1)" }) + "/\(fileName)"
    }
    
    let shardPath = FileManager.sharedPath
    
    typealias DTO = VideoCodesDTO
    
    public init() { }
    
    public func save(code: String) {
        
        let filePath = shardPath.appending(path: absolutePath)
        
        if !manager.fileExists(atPath: filePath.path()) {
            
            // 폴더생성
            let directoryPath = shardPath.appending(path: directories.last ?? "")
            
            try? manager.createDirectory(at: directoryPath, withIntermediateDirectories: false)
            
            let extData = DTO(codes: [code])
            
            guard let encoded = try? JSONEncoder().encode(extData) else { fatalError() }
            
            manager.createFile(atPath: filePath.path(), contents: encoded)
            
        } else {
            
            // 파일이 존재하는 경우
            guard let data: Data = try? Data(contentsOf: filePath) else { fatalError() }
            
            let willWriteData: Data?
            
            if var decoded = try? JSONDecoder().decode(DTO.self, from: data) {
                
                decoded.codes.append(code)
                
                guard let encoded = try? JSONEncoder().encode(decoded) else { fatalError() }
                
                willWriteData = encoded
            } else {
                
                // 파일이 비어있는 경우
                let codeDTO = DTO(codes: [code])
                
                guard let encoded = try? JSONEncoder().encode(codeDTO) else { fatalError() }
                
                willWriteData = encoded
            }
            
            guard (try? willWriteData?.write(to: filePath)) != nil else { fatalError() }
        }

    }
    
    public func get() -> [Domain.SummaryIntiationEntitiy] {
        
        let filePath = shardPath.appending(path: absolutePath)
        
        if manager.fileExists(atPath: filePath.path()) {
            
            guard let data: Data = try? Data(contentsOf: filePath) else { fatalError() }
            
            if data.isEmpty { return [] }
            
            guard let decoded = try? JSONDecoder().decode(DTO.self, from: data) else { fatalError() }
            
            let entities = decoded.codes.map { SummaryIntiationEntitiy(videoCode: $0) }
            
            // 파일 내용 추출후 파일을 비운다.
            if let fileHandle = try? FileHandle(forWritingTo: URL(fileURLWithPath: filePath.path())) {
                
                // 파일 내용을 비우기
                fileHandle.truncateFile(atOffset: 0)
                
                // 파일 닫기
                fileHandle.closeFile()
            }
            
            return entities
        }
        
        return []
    }
}
