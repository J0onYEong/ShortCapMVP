import UIKit
import WebKit
import Domain

public class DetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var summaryTextView: UITextView!
    
    @IBOutlet weak var summaryHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var keyWordStack: UIStackView!
    
    var entity: SummaryResultEntity?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // 타이틀 변경
        titleLabel.text = entity?.title ?? "제목 없음"
        
        // webView설정
        if let urlString = entity?.url, let contentUrl = URL(string: urlString) {
            
            webView.load(URLRequest(url: contentUrl))
        } else {
            
            webView.alpha = 0
        }
        
        // summary text
        summaryTextView.delegate = self
        summaryTextView.text = entity?.summary ?? ""
        summaryTextView.isScrollEnabled = false
        
        // keywords
        
        entity?.keywords.forEach({ keyword in
            
            let labelView = UILabel()
            
            labelView.text = keyword
            
            keyWordStack.addArrangedSubview(labelView)
        })
    }
    

    
    // MARK: - Navigation

}

extension DetailViewController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.contentSize
        
        summaryHeightConst.constant = size.height
    }
}
