//
//  EnviarMensaje.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

class EnviarMensaje: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VCFinalDelegate {

    // MARKS: Declare Outlets
    @IBOutlet weak var asunto: UITextField!
    @IBOutlet weak var mensaje: UITextField!
    @IBOutlet weak var myImageView: UIImageView!
    
    // MARKS: Declare var
    var addfoto = false
    var addloc = false
    var FechaImagen = ""
    var Imagen = ""
    var image64 = ""
    var locationManager = CLLocationManager()
    var Localizacion = ""
    
    // 1. Declare a new variable to hold data sent from SecondViewController
    var valueSentFromSecondViewController:String?

    func finishPassing(string: String) {
        print("Notified")
        Localizacion = string
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
    }
    

    // 2. Add viewWillAppear to display the value of the variable
    override func viewDidAppear(_ animated: Bool) {
        print("PASS DATA SUCCESSFUL IN VIEW DID APPEAR = \(Localizacion)")

    }

    //4. Implement MyProtocol's function to make FirstViewContoller conform to MyProtocol
    // MARK: MyProtocol functions

    

    
    
    // MARKS: Declare Dialog Message
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title:"Atención", message: userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "Vale", style: UIAlertActionStyle.default, handler: nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated: true, completion: nil);
    }
    
    // MARKS: Declare Picker Methods
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        myImageView.image = image
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "es")
        dateformatter.setLocalizedDateFormatFromTemplate("hh:mm:ss")
        dateformatter.timeStyle = DateFormatter.Style.medium
        
        let Imagen1 = dateformatter.string(from: Date())
        
        addfoto = true
        FechaImagen = "\(Imagen1)\(".jpg")"
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        myImageView.image! = image
        
        self.dismiss(animated: true, completion: nil);
    }
    
    func encodeImageToBase64(image : UIImage) -> String{
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let strBase64 = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return strBase64!
    }
    
    
    // MARKS: Declare Actions
    @IBAction func backBtn(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addLocationBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        let vc = storyboard.instantiateViewController(withIdentifier: "Localizacion") as! Localizacion
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func cameraBtn(_ sender: EnviarMensaje) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
            addfoto=true
        }
    }
    
    @IBAction func galleryIcon(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
            addfoto=true
        }
    }
    
    @IBAction func sendBtn(_ sender: Any) {
        
        // FCM TOKEN
        let defaults = UserDefaults.standard
        if let FCMToken = defaults.string(forKey: "FCMToken") {
            print("FCM TOKEN = \(FCMToken)")
        }
         
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        let Asunto = asunto.text ?? "";
        let Mensaje = mensaje.text ?? "";
        let Identificador = defaults.string(forKey: "id") ?? "";
        let Localizacion = self.Localizacion
       
        if addfoto == true {
            
            image64 = encodeImageToBase64(image: myImageView.image!)
        } else {
            
            image64 = ""
        }
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "es")
        dateformatter.setLocalizedDateFormatFromTemplate("ddMMyy hh:mm:ss")
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.medium
        
        let Fecha = dateformatter.string(from: Date()) ;
        
        Imagen = FechaImagen.replacingOccurrences(of: "/", with: "")
        Imagen = FechaImagen.replacingOccurrences(of: ":", with: "")
        
        // Comprobar si hay img adjunta
        if (Imagen.isEmpty) {
            self.displayMyAlertMessage(userMessage: "Por favor, rellena todos los campos y añade foto.")
            return;
        }
        
        // Comprobar si hay campos vacíos
        if (Asunto.isEmpty) , (Mensaje.isEmpty) {
            
            OperationQueue.main.addOperation{
                self.displayMyAlertMessage(userMessage: "Por favor, rellena todos los campos y añade foto.")
            }
            
        } else {
            
            SVProgressHUD.show(withStatus: "Enviando mensaje...")
            
            // Enviar mensaje al server
            var request = URLRequest(url: URL(string: "http://enalcoi.info/android/webservicemuro/addcommentIOS.php")!)
            request.httpMethod = "POST"
            
            // Introducimos las variables que vamos a enviar por php
            let body = "asunto=\(Asunto)&message=\(Mensaje)&nameimagen=\(Imagen)&identificador=\(Identificador)&fecha=\(Fecha)&localizacion=\(Localizacion)&image64=\(image64)"
            
            request.httpBody = body.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard let data = data, error == nil else {
                    
                    // check for fundamental networking error
                    print("error=\(error!)")
                    return
                }
                
                SVProgressHUD.dismiss()
                
                //Obtenemos respuesta de la bd
                let responseString = String(data: data, encoding: .utf8)
                
                //Mostramos por terminal
                print("RESPUESTA = \(responseString!)")
                
                //Si la respuesta contiene 1, el usuario ha enviado correctamente el mensaje
                if ((responseString?.range(of: "1")) != nil){
                    
                    OperationQueue.main.addOperation{
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListadoMensajes") as! ListadoMensajes
                        //ListadoMensajes.delegate = self
                        self.present(vc, animated: true)

                    }
                }
                
                //Si la respuesta contiene un 0, mostramos el siguiente mensaje
                if ((responseString?.range(of: "0")) != nil){
                    
                    OperationQueue.main.addOperation{
                        self.displayMyAlertMessage(userMessage: "Por favor, rellena todos los campos y añade foto.")
                    }
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    
                    // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                } else {
                    print("Mensaje enviado correctamente.")
                }
            }
            task.resume()
        }
    }
    


}


