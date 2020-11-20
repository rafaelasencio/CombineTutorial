//
//  Textfield.swift
//  CombineWWDC
//
//  Created by RafaelAsencio on 17/11/2020.
//

import UIKit

class TextField: UITextField {
    
    //MARK: - Inspectables
    @IBInspectable var leftPadding: CGFloat = 0
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }

    //MARK: - Properties
    var padding: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10 + leftPadding + (leftView?.frame.width ?? 0), bottom: 0, right: 5)
    }
    
    var isValidInput: Bool = false {
        didSet {
            updateView()
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setTextField()
    }
    
    //MARK: - Functions
    func updateView() {
        DispatchQueue.main.async { [weak self] in
            if let image = self?.leftImage {
                self?.leftViewMode = UITextField.ViewMode.always
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                imageView.tintColor = self!.isValidInput ? .green : .red
                if self?.text == "" {
                    imageView.tintColor = .lightGray
                }
                self?.leftView = imageView
            } else {
                self?.leftViewMode = UITextField.ViewMode.never
                self?.leftView = nil
            }
        }
    }
    
    func setTextField(){
        //Basic texfield Setup
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.height / 2
        
        //To apply padding
        let paddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = UITextField.ViewMode.always
    }
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    // Provides left padding for texts
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}

extension TextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: newValue!, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
        }
    }
}
