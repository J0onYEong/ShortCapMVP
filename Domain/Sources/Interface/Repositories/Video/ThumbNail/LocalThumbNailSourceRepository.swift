import Foundation

public protocol LocalThumbNailSourceRepository {
    
    func save(
        videoCode: String,
        url: String
    )
    
    func fetch(videoCode: String) -> String?
}
