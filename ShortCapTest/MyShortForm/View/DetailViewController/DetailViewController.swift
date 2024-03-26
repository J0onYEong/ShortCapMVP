//
//  DetailViewController.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/17/24.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var summaryTextView: UITextView!
    
    @IBOutlet weak var summaryHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var keyWordStack: UIStackView!
    
    var contentViewModel: SCDetailInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 타이틀 변경
        titleLabel.text = contentViewModel?.contentTitle ?? "제목 없음"
        
        // webView설정
        if let contentUrl = contentViewModel?.contentUrl {
            
            webView.load(URLRequest(url: contentUrl))
        } else {
            
            webView.alpha = 0
        }
        
        // summary text
        summaryTextView.delegate = self
        summaryTextView.text = contentViewModel?.contentSummary ?? ""
        summaryTextView.isScrollEnabled = false
        
        // keywords
        contentViewModel?.contentKeywords.forEach({ keyword in
            
            let labelView = UILabel()
            
            labelView.text = keyword
            
            keyWordStack.addArrangedSubview(labelView)
        })
    }
    

    
    // MARK: - Navigation

}

extension DetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.contentSize
        
        summaryHeightConst.constant = size.height
    }
}
