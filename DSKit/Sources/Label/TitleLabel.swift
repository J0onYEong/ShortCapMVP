import UIKit


public class PretendardLabel: UILabel {
    
    public enum State { case normal, focused }
    
    public var focusedColor: UIColor = DSColor.mainBlue300.color
    public var normalColor: UIColor = DSColor.black300.color
    
    public var state: State = .normal {
        willSet {
            if newValue == .focused {
                
                self.textColor = focusedColor
                self.font = PretendardFontWeight.semiBold.getFont(size: self.font.pointSize)
            } else {
                
                self.textColor = normalColor
                self.font = PretendardFontWeight.regular.getFont(size: self.font.pointSize)
            }
        }
    }
    
    /// 고정된 텍스트 크기
    public init(text: String, fontSize: CGFloat, fontWeight: PretendardFontWeight, isAutoResizing: Bool = false) {
        super.init(frame: .zero)
        
        self.font = fontWeight.getFont(size: fontSize)
        self.text = text
        self.adjustsFontSizeToFitWidth = isAutoResizing
        if isAutoResizing { self.minimumScaleFactor = fontSize-3 }
    }
    
    public required init?(coder: NSCoder) { fatalError() }
}
