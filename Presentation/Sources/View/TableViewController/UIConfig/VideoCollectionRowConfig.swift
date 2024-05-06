import Foundation

enum VideoCollectionViewConfig {
    
    // TableInset
    static let horizontalInset: CGFloat = 20
    
    // RowHeight
    static var rowHeight: CGFloat { thumbNailHeight }
    
    // ThumbNail
    static let thumbNailHeight: CGFloat = 160
    static let thumbNailWidth: CGFloat = 120
    static var thumbNailSize: CGSize { CGSize(width: thumbNailWidth, height: thumbNailHeight) }
}
