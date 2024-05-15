import Foundation
import Domain

struct VideoSubCategoryDTO: Codable {
    
    let subCategories: [SubCategory]
    
    enum CodingKeys: String, CodingKey {
        
        case subCategories = "subCategoryList"
    }
}

struct SubCategory: Codable {
    let subCategory: String
    let categoryId: Int
    
    private init(subCategory: String, categoryId: Int) {
        self.subCategory = subCategory
        self.categoryId = categoryId
    }

    enum CodingKeys: String, CodingKey {
        case subCategory
        case categoryId
    }
}

extension VideoSubCategoryDTO {
    
    func toEntity() -> [VideoSubCategory] {
        
        self.subCategories.map {
            
            VideoSubCategory(name: $0.subCategory, categoryId: $0.categoryId)
        }
    }
}
