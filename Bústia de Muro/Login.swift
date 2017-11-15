//
//  Login.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD

class Login: UIViewController {
    

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var userdni: UITextField!
    @IBOutlet weak var userpassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginBtn.layer.cornerRadius = 20
        self.hideKeyboardWhenTappedAround()
    }
    
    
    // MARKS: Display Dialog Message
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title:"Atención", message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "Vale", style: UIAlertActionStyle.default, handler: nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated: true, completion: nil);
    }
    
    
    // MARKS: Display Login JSON to DB
    func loginBM() {
        
        // escribir valores para dni y contraseña
        let userDni = userdni.text ?? "";
        let userPassword = userpassword.text ?? "";
        
        // Comprobar si hay campos vacíos
        if(userDni.isEmpty), (userPassword.isEmpty) {
            
            displayMyAlertMessage(userMessage: "Por favor, rellena todos los campos");
            return;
        }
        
        // Enviamos info
        SVProgressHUD.show(withStatus: "Loading Messages...")
        
        Alamofire.request("http://enalcoi.info/android/webservicemuro/login.php?dni=\(userDni)&password=\(userPassword)", method: .post).responseData { response in

            debugPrint("Response Login Info: \(String(describing: response))")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                
                // original server data as UTF8 string
                print("Data: \(utf8Text)")
                
                if ((utf8Text.range(of: "1")) != nil){
                    OperationQueue.main.addOperation{
                        self.displayMyAlertMessage(userMessage: "El usuario o la contraseña no coinciden");                        //return;
                    }
                    
                    
                } else {
                    
                    print("Error")
                }
                
                //Si la respuesta contiene un 0, el suario no existe
                if ((utf8Text.range(of: "0")) != nil){
                    
                        self.displayMyAlertMessage(userMessage: "El usuario o la contraseña no coinciden");                        return;
                }
             
            }

            // Guardar variable id
            let defaults = UserDefaults.standard
            defaults.set(userDni, forKey: "id")
            

            // Si todo está ok, pasamos a ListadoMensajes
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListadoMensajes") as! ListadoMensajes
            self.present(vc, animated: true)
            SVProgressHUD.dismiss()
            
        }
    }
    
    
    // MARKS: Display Actions
    @IBAction func backBtn(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func loginBtn(_ sender: Any) {
        
        loginBM()
    }
    
    
}

// MARKS: Extension 4 dismiss keyboard
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
