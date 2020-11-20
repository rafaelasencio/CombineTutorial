//
//  ViewController.swift
//  CombineWWDC
//
//  Created by RafaelAsencio on 14/11/2020.
//

import UIKit
import Combine

class RegisterController: UIViewController {
    
    //MARK: - Oulets
    @IBOutlet weak var signupButton: Button!
    @IBOutlet weak var tfUsername: TextField!
    @IBOutlet weak var tfPassword: TextField!
    @IBOutlet weak var tfRepeatPassword: TextField!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    
    //MARK: - Variables
    
    var isValidUser: Bool = false
    var isValidPassword: Bool = false
    var signupButtomStream: AnyCancellable? //guardar la subscripcion
    
    //MARK: - Publishers
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var passwordAgain: String = ""
    
    var validatedUsername: AnyPublisher<String?, Never> {
        return $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { username in
                return Future { promise in //Devuelve un clousure con success or failure
                    self.usernameAvailable(username) { available in
                        promise(.success(available ? username : nil))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    var validatedPassword: AnyPublisher<String?, Never> {
        return Publishers.CombineLatest($password, $passwordAgain).map { pass, passAgain -> String? in
            guard pass == passAgain, pass.count > 5 else { return nil }
            return pass
        }
        .map {
            $0 == "password" ? nil : $0
        }
        .eraseToAnyPublisher()
    }
    var validateCredentials: AnyPublisher<(String, String)?, Never> {
        return Publishers.CombineLatest(validatedUsername, validatedPassword)
            .map { username, password in
                self.tfUsername.isValidInput = username != nil ? true : false
                self.tfPassword.isValidInput = password != nil ? true : false
                self.tfRepeatPassword.isValidInput = password != nil ? true : false
                
                guard let uName = username, let pass = password else { return nil }
                return (uName, pass)
            }
            .eraseToAnyPublisher()
    }
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.isHidden = true
        self.signupButtomStream = self.validateCredentials
            .map { $0 != nil }
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: signupButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("OK")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: - Functions
    let availablesUsernames = ["Juan","Pepe","Pedro", "Beyka"]
    func usernameAvailable(_ username: String, completion:(Bool)->()) {
        availablesUsernames.contains(username) ? completion(true) : completion(false)
    }
    
    //MARK: - Actions
    @IBAction func passwordChanged(_ sender: UITextField) {
        password = sender.text ?? ""
    }
    
    @IBAction func passwordAgainChanged(_ sender: UITextField) {
        passwordAgain = sender.text ?? ""
    }
    
    @IBAction func usernameValid(_ sender: UITextField) {
        username = sender.text ?? ""
    }
    
    @IBAction func handleRegistration(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.activityView.isHidden = false
            self.activityView.startAnimating()
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.dismiss(animated: true)
        }


    }
}

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
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.tintColor = isValidInput ? .green : .red
            if self.text == "" {
                imageView.tintColor = .lightGray
            }
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
    }
    
    func setTextField(){
        //Basic texfield Setup
        //To apply corner radius
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

//    enum ValidationTextfield: Int {
//        case valid
//        case invalid
//        case notTapped
//
//        var color: CGColor {
//            switch self {
//            case .valid: return UIColor.green.cgColor
//            case .invalid: return UIColor.red.cgColor
//            case .notTapped: return UIColor.lightGray.cgColor
//            }
//        }
//        init(index: Int) {
//            switch index {
//            case 0: self = .valid
//            case 1: self = .invalid
//            case 2: self = .notTapped
//            default: self = .notTapped
//            }
//        }
//    }
