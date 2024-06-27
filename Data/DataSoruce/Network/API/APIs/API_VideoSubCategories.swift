import Foundation

extension ShortcapAPI {
    
    func fetchVideoSubCategoriesFor(mainCategoryName: String) -> RequestBox<ResponseDTOWrapper<VideoSubCategoryDTO>> {
        
        let endPoint = Endpoint(
            baseURL: configuration.baseURL,
            path: "api/categories",
            method: .get,
            headerParameters: configuration.baseHeader,
            queryParameters: [
                "mainCategory" : mainCategoryName
            ]
        )
        return RequestBox(
            endPoint: endPoint,
            afInterceptor: tokenInterceptor.afTokenInterceptor
        )
        
    }
}
