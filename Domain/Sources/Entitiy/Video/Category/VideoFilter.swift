import Foundation

public class VideoFilter {
    
    public let mainCategoryId: Int
    public let subCategoryId: Int
    public let state: State
    
    public enum State {
        case all
        case specific
    }
    
    public init(mainCategoryId: Int, subCategoryId: Int, state: State = .specific) {
        self.mainCategoryId = mainCategoryId
        self.subCategoryId = subCategoryId
        self.state = state
    }
    
    public static let all: VideoFilter = .init(mainCategoryId: -1, subCategoryId: -1, state: .all)
}

extension VideoFilter: Equatable {
    
    public static func == (lhs: VideoFilter, rhs: VideoFilter) -> Bool {
        
        lhs.mainCategoryId == rhs.mainCategoryId &&
        lhs.subCategoryId == rhs.subCategoryId &&
        lhs.state == rhs.state
    }
}
