import UIKit
import Kingfisher

public extension UIImageView {
    
    func setImage(with urlString: String) {
        
        ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
            
            switch result {
            case .success(let value):
                
                if let image = value.image {
                    
                    //캐시가 존재하는 경우
                    self.image = image
                    
                } else {
                    
                    //캐시가 존재하지 않는 경우
                    guard let url = URL(string: urlString) else { return }
                    
                    let resource = ImageResource(downloadURL: url, cacheKey: urlString)
                    
                    let processor = DownsamplingImageProcessor(size: self.bounds.size)
                    
                    self.kf.setImage(
                        with: resource,
                        options: [
                            .processor(processor),
                            .scaleFactor(UIScreen.main.scale),
                            .transition(.fade(0.5)),
                            .cacheOriginalImage,
                        ]
                    )
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
