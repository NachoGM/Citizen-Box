//
//  Inicio.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FacebookCore
import FacebookLogin
import SafariServices

class Inicio: UIViewController, FBSDKLoginButtonDelegate {
    
    
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title:"Atención", message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "Vale", style: UIAlertActionStyle.default, handler: nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated: true, completion: nil);
    }
    
    
    

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var facebookBtn: FBSDKLoginButton!
    
    @IBAction func loginBtn(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        self.present(vc, animated: true)
    }
    
    
    @IBAction func registerBtn(_ sender: Any) {
       
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Registro") as! Registro
        self.present(vc, animated: true)
    }
    

    
    var nombreFbArray = [String]()
    var imagenFbPerfil = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let FCMToken = defaults.string(forKey: "FCMToken") {
            // Print FCM Token
            print("FCMToken = \(FCMToken)")
        }
        
        facebookBtn.readPermissions = ["public_profile", "email", "user_friends"]
        facebookBtn.delegate = self
        loginBtn.layer.cornerRadius = 3
        
        view.addSubview(facebookBtn)
    }

    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            
            print(error.localizedDescription)
            return
        }
        
        if (result.token) != nil {
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    // Declaramos las variables que nos interesan del JSON
                    let userFacebook = (result as AnyObject).value(forKey: "name")
                    let imageProfile = (result as AnyObject).value(forKey: "picture")
                    let userid = (result as AnyObject).value(forKey: "id")
                    
                    // Guardamos las variables localmente
                    UserDefaults.standard.set(userFacebook, forKey: "name")
                    UserDefaults.standard.set(userid, forKey: "id")
                    UserDefaults.standard.set(imageProfile, forKey: "picture")
                    
                    UserDefaults.standard.synchronize()
                    
                    print("REGISTRO POR FACEBOOK = \(result!)")
                }
            })
        }
        
        // escribir valores para dni y contraseña
        let Password = "1234";
        
        let defaults = UserDefaults.standard
        
        let Name = defaults.string(forKey: "name") ?? ""
        
        let url = NSURL(string: "http://enalcoi.info/android/webservicemuro/register.php")
        
        // metodo para esta fila
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        // body to be apppened to url
        let body = "dni=\(FBSDKAccessToken.current().userID ?? "")&password=\(Password)&username=\(Name)"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        // proceed request
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error == nil {
                
                // get main queue in code process to comunicate back to UI
                DispatchQueue.main.async (execute:  {
                    
                    do {
                        // get json result
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        // assign json to new var parseJSON in guard/ secure way
                        guard let parseJSON = json else {
                            print("Error mientras se copiaba")
                            return
                        }
                        
                        let id = parseJSON["dni"]
                        
                        if id != nil {
                            print (parseJSON)
                        }
                        
                    } catch {
                        print("Ha habido un error:\(error)")
                    }
                })
                
            } else {
                print("error:\(String(describing: error))")
            }
        }).resume()
        
        // Si todo está correcto, pasamos a la siguiente vista
        let Protected = self.storyboard?.instantiateViewController(withIdentifier: "Protected") as! Protected
        self.present(Protected, animated: true)
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Loged out...")
    }
    
    

}
