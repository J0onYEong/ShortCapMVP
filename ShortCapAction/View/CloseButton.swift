import UIKit

class CloseButton: UIButton {
    
    var activityIndicator: UIActivityIndicatorView = {
        
        let activityIndicator = UIActivityIndicatorView()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .lightGray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
        
    }()
    
    required init?(coder: NSCoder) {
        
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        
        setInitialSetting()
    }
    
    private let doneString: NSAttributedString = {
        
        let attribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor : UIColor.black
        ]
        
        return NSAttributedString(string: "닫기", attributes: attribute)
    }()
    
    private let closeString: NSAttributedString = {
        
        let attribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor : UIColor.white
        ]
        
        return NSAttributedString(string: "닫기", attributes: attribute)
    }()
    
    func setInitialSetting() {
        
        self.setTitle("", for: .normal)

        self.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            activityIndicator.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            activityIndicator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.height/2
    }
    
    func loading() {
        
        self.setTitle("", for: .normal)
        self.isEnabled = false
        UIView.animate(withDuration: 1.0) {
            
            self.backgroundColor = .gray
        }
        
        activityIndicator.startAnimating()
    }
    
    func stopLoading(isSuccess: Bool = true) {
        
        self.isEnabled = true
        
        let buttonTitle = NSMutableAttributedString(string: "닫기")
        
        let textRange = NSRange(
            location: 0,
            length: buttonTitle.length
        )
        
        buttonTitle.setAttributes(
            [
                .foregroundColor : (isSuccess ? UIColor.black : UIColor.white)
            ],
            range: textRange
        )
    
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) {

            self.setAttributedTitle(buttonTitle, for: .normal)
            
            self.backgroundColor = isSuccess ? .green : .systemPink
        }
        
        activityIndicator.stopAnimating()
    }
    
}
