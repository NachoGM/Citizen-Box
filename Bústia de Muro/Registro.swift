//
//  Registro.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit

class Registro: UIViewController {
    
    // MARKS: Display Outlets
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var userdni: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var userpassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBtn.layer.cornerRadius = 20
        self.hideKeyboardWhenTappedAround()
        
    }
    
    
    // MARKS: Display Dialog Message
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title:"Atención", message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "Vale", style: UIAlertActionStyle.default, handler: nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated: true, completion: nil);
    }
    
    // MARKS: Display Register JSON to DB Native
    func registerJSON() {
        
        let userDni = userdni.text!;
        let userName = username.text!;
        let userPassword = userpassword.text!;
        let userRepeatPassword = repeatPassword.text!;
        
        // Comprobar si hay campos vacíos
        if(userDni.isEmpty), (userName.isEmpty), (userPassword.isEmpty), (userRepeatPassword.isEmpty) {
            
            // Si no rellenan los campos del registro, el placeholder se pondrá en rojo
            userdni.attributedPlaceholder = NSAttributedString(string: "DNI con Letra", attributes: [NSForegroundColorAttributeName: UIColor.gray])
            
            username.attributedPlaceholder = NSAttributedString(string: "Nombre de usuario", attributes: [NSForegroundColorAttributeName: UIColor.gray])
            
            userpassword.attributedPlaceholder = NSAttributedString(string: "********", attributes: [NSForegroundColorAttributeName: UIColor.gray])
            
            repeatPassword.attributedPlaceholder = NSAttributedString(string: "********", attributes: [NSForegroundColorAttributeName: UIColor.gray])
            
            // Desplegar mensaje de confirmación
            displayMyAlertMessage(userMessage: "Por favor, rellena todos los campos");
            return;
        }
        
        // Comprobar si las contraseñas coinciden
        if (userPassword != userRepeatPassword) {
            
            displayMyAlertMessage(userMessage: "Las contraseñas no coinciden");
            return;
        }
        
        // Guardar los datos en bbdd
        var request = URLRequest(url: URL(string: "http://enalcoi.info/android/webservicemuro/register.php")!)
        request.httpMethod = "POST"
        
        let postString = "dni=\(userDni)&username=\(userName)&password=\(userPassword)";
        request.httpBody = postString.data(using: String.Encoding.utf8)!
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString ?? "")")
            
            if ((responseString?.range(of: "1")) != nil){
                
                OperationQueue.main.addOperation{
                    
                    // Si todo está ok, desplegamos la alerta y pasamos a ListadoMensajes, donde se recargará el JSON incluyendo el mensaje enviado
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                    self.present(vc, animated: true)
                }
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }  
        }
        task.resume()
        
        // Desplegar mensaje  de confirmación
        let myAlert = UIAlertController(title:"Atención", message: "Te has registrado correctamente. ¡Muchas gracias!", preferredStyle: UIAlertControllerStyle.alert);
        
        let okAction = UIAlertAction(title: "Vale", style: UIAlertActionStyle.default){ action in
            self.dismiss(animated: true, completion: nil);
        }
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated: true, completion: nil);
    }
    
    
    // MARKS: Display Actions 
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createBtn(_ sender: Any) {
        
        registerJSON()
    }


}

