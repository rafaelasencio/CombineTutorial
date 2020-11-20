//
//  MainController.swift
//  CombineWWDC
//
//  Created by RafaelAsencio on 17/11/2020.
//

import UIKit

class MainController: UIViewController {
    
    @IBOutlet weak var lbWelcome: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGroupedBackground
        self.lbWelcome.alpha = 0
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLabel()
    }
    
    func animateLabel(){
        UIView.animate(withDuration: 1.5)  {
            self.lbWelcome.alpha = 1
        }
    }
    
    
}
