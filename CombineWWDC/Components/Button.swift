//
//  Button.swift
//  CombineWWDC
//
//  Created by RafaelAsencio on 17/11/2020.
//

import UIKit

class Button: UIButton {
    
    var borderWidth: CGFloat = 1.0
    var borderColor = UIColor.clear.cgColor
    var backColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    func setup(){
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.height / 4
        self.layer.borderColor = UIColor.systemGroupedBackground.cgColor
//        self.layer.borderWidth = borderWidth
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.2
    }
    override open  var isEnabled: Bool {
        didSet {
            setStyleForStatus(isEnabled: isEnabled)
        }
    }
    
    private func setStyleForStatus(isEnabled: Bool){
        self.backgroundColor = isEnabled ?  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1): #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.setTitleColor(isEnabled ?  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
    }
}
