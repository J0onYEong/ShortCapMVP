import UIKit

public enum PretendardFontWeight {
    case black, bold, extraBold, extraLight, light, medium, regular, semiBold, thin
    
    public func getFont(size: CGFloat = 17.0) -> UIFont {
        
        switch self {
        case .black:
            FontFamily.Pretendard.black.font(size: size)
        case .bold:
            FontFamily.Pretendard.bold.font(size: size)
        case .extraBold:
            FontFamily.Pretendard.extraBold.font(size: size)
        case .extraLight:
            FontFamily.Pretendard.extraLight.font(size: size)
        case .light:
            FontFamily.Pretendard.light.font(size: size)
        case .medium:
            FontFamily.Pretendard.medium.font(size: size)
        case .regular:
            FontFamily.Pretendard.regular.font(size: size)
        case .semiBold:
            FontFamily.Pretendard.semiBold.font(size: size)
        case .thin:
            FontFamily.Pretendard.thin.font(size: size)
        }
    }
}
