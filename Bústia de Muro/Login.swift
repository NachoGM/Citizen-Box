//
//  Login.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit

class Login: UIViewController {
    
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title:"Atención", message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "Vale", style: UIAlertActionStyle.default, handler: nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated: true, completion: nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginBtn.layer.cornerRadius = 20
        self.hideKeyboardWhenTappedAround()

    }

    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var userdni: UITextField!
    
    @IBOutlet weak var userpassword: UITextField!
    
    @IBAction func backBtn(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        
        // escribir valores para dni y contraseña
        let userDni = userdni.text ?? "";
        let userPassword = userpassword.text ?? "";
        
        // Comprobar si hay campos vacíos
        if(userDni.isEmpty), (userPassword.isEmpty) {
            
            displayMyAlertMessage(userMessage: "Por favor, rellena todos los campos");
            return;
        }
        
        // Guardar los datos en bbdd
        var request = URLRequest(url: URL(string: "http://enalcoi.info/android/webservicemuro/login.php")!)
        request.httpMethod = "POST"
        
        let postString = "dni=\(userDni)&password=\(userPassword)";
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            // Obtenemos respuesta de la bd
            let responseString = String(data: data, encoding: .utf8)
            
            // Mostramos por terminal
            print("responseString = \(responseString ?? "")")
            
            //Si la respuesta contiene 1, el usuario exite en la bd
            if ((responseString?.range(of: "1")) != nil){
                
                OperationQueue.main.addOperation{
                    
                    self.displayMyAlertMessage(userMessage: "Te has logueado correctamente")
                    return;
                }
            }
            
            //Si la respuesta contiene un 0, el suario no existe
            if ((responseString?.range(of: "0")) != nil){
                
                OperationQueue.main.addOperation{
                    self.displayMyAlertMessage(userMessage: "El usuario o la contraseña no coinciden")
                }
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
        }
        task.resume()
        
        // Guardar variable
        let defaults = UserDefaults.standard
        defaults.set(userDni, forKey: "id")
        
        // Si todo está ok, pasamos a ListadoMensajes
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListadoMensajes") as! ListadoMensajes
        self.present(vc, animated: true)
    }
    /*
    //Calls this function when the tap is recognized.
    override func dismissKeyboard() {
        
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    */
    
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
