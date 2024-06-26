import Foundation

extension VideoDetailEntity {
    
    func toDTO() -> VideoDetailDTO {
        
        VideoDetailDTO(
            title: title ?? "",
            description: des ?? "",
            keywords: keywords?.components(separatedBy: ",") ?? [],
            url: url ?? "",
            summary: summary ?? "",
            address: address ?? "",
            createdAt: createdAt ?? "",
            platform: platform ?? "",
            mainCategory: mainCategory ?? "",
            mainCategoryId: Int(mainCategoryId),
            subCategory: subCategory ?? "",
            subCategoryId: Int(subCategoryId),
            videoCode: videoCode ?? ""
        )
    }
}
