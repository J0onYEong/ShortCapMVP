import Foundation
import Domain

struct VideoSubCategoryDTO: Codable {
    
    let subCategories: [SubCategory]
    
    enum CodingKeys: String, CodingKey {
        
        case subCategories = "subCategoryList"
    }
}

struct SubCategory: Codable {
    let categoryName: String
    let categoryId: Int
    let summaryCount: Int
    let updateAt: String?
}

extension VideoSubCategoryDTO {
    
    func toEntity() -> [VideoSubCategory] {
        
        self.subCategories.map {
            
            VideoSubCategory(name: $0.categoryName, categoryId: $0.categoryId)
        }
    }
}
