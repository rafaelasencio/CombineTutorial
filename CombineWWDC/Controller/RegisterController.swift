//
//  RegisterController.swift
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
    private var isValidUser: Bool = false
    private var isValidPassword: Bool = false
    private var signupButtomStream: AnyCancellable? //guardar la subscripcion

    //MARK: - Publishers
    @Published private var username: String = ""
    @Published private var password: String = ""
    @Published private var passwordAgain: String = ""
        
    private var validatedUsername: AnyPublisher<String?, Never> {
        return $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { username in
                
                return Future { promise in //Devuelve un clousure con success or failure
                    self.checkUserAvailability(username) { available in
                        promise(.success(available ? username : nil))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var validatedPassword: AnyPublisher<String?, Never> {
        return Publishers.CombineLatest($password, $passwordAgain).map { pass, passAgain -> String? in
            guard pass == passAgain, pass.count > 5 else { return nil }
            return pass
        }
        .map {
            $0 == "password" ? nil : $0
        }
        .eraseToAnyPublisher()
    }
    
    private var validateCredentials: AnyPublisher<(String, String)?, Never> {
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: - Functions
    private func checkUserAvailability(_ username: String, completion: @escaping(Bool)->()){
        URLSession.shared.dataTask(with: API.Endpoints.users.url) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200,
                  error == nil else {
                completion(false)
                return
            }
            do {
                let responseObject = try JSONDecoder().decode([User].self, from: data)
                let filter = responseObject.filter {$0.username == username}
                filter.isEmpty ? completion(true) : completion(false)
            } catch {
                completion(false)
                print(error)
            }
        }.resume()
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
            self.dismiss(animated: true) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MainController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
    
    
}


