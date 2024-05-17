import UIKit

public class PartHighLightLabel: UILabel {
    
    private let defaultFont: PretendardFontWeight
    private let highLightFont: PretendardFontWeight
     
    private let defaultFontColor: UIColor
    private let highLightFontColor: UIColor
    
    private let fontSize: CGFloat
    
    public init(
        text: String,
        size: CGFloat,
        range: NSRange,
        defaultFont: PretendardFontWeight = .regular,
        highLightFont: PretendardFontWeight = .semiBold,
        defaultFontColor: UIColor = DSColor.black300.color,
        highLightFontColor: UIColor = DSColor.mainAqua200.color
    ) {
        self.fontSize = size
        self.defaultFont = defaultFont
        self.highLightFont = highLightFont
        self.defaultFontColor = defaultFontColor
        self.highLightFontColor = highLightFontColor
        
        let attributedString = NSMutableAttributedString(string: text)
        
        let fullRange = NSRange(location: 0, length: text.utf16.count)
            
        attributedString.addAttribute(.foregroundColor, value: defaultFontColor, range: fullRange)
        attributedString.addAttribute(.font, value: defaultFont.getFont(size: size), range: fullRange)
        
        attributedString.addAttribute(.foregroundColor, value: highLightFontColor, range: range)
        attributedString.addAttribute(.font, value: highLightFont.getFont(size: size), range: range)

        super.init(frame: .zero)
        
        self.attributedText = attributedString
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public func apply(text: String, part: String) {
        
        if !text.contains(part) {
            
            print("‼️PartHighLightLabel.apply: 하이라이트 텍스트가 설정 오류")
            
            return
        }
        
        let attributedString = NSMutableAttributedString(string: text)

        let range = (text as NSString).range(of: part)
        
        let fullRange = NSRange(location: 0, length: text.utf16.count)
        
        attributedString.addAttribute(.foregroundColor, value: defaultFontColor, range: fullRange)
        attributedString.addAttribute(.font, value: defaultFont.getFont(size: fontSize), range: fullRange)

        attributedString.addAttribute(.foregroundColor, value: highLightFontColor, range: range)
        attributedString.addAttribute(.font, value: highLightFont.getFont(size: fontSize), range: range)

        self.attributedText = attributedString
    }
}

