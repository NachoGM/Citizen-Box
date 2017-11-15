//
//  ListadoMensajes.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON

let defaults = UserDefaults.standard
let Identificador = defaults.string(forKey: "id") ?? ""

class ListadoMensajes: UIViewController, UITableViewDataSource,UITableViewDelegate {

    // MARKS: Declare Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARKS: Declare var
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var refresh = UIRefreshControl()
    var asuntoArray = [String]()
    var fechaArray = [String]()
    var imgURLArray = [String]()
    var mensajeArray = [String]()
    var respuestaArray = [String?]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load FCM Token
        let defaults = UserDefaults.standard
        if let FCMToken = defaults.string(forKey: "FCMToken") {
            print("FCM TOKEN = \(FCMToken)")
        }
        
        // Load Refresh Control
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        self.refresh.backgroundColor = UIColor.white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = self.refresh
        
        // Load JSON Response
        self.downloadJsonWithTask()
        //self.jsonMovies()
        // Load Date
        self.fecha()
        self.view.addSubview(tableView!)
    }
    
    
    // MARKS: Declare Date Format
    func fecha() {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "es")
        dateformatter.setLocalizedDateFormatFromTemplate("ddMMyy hh:mm:ss")
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.medium
        
        let Fecha = dateformatter.string(from: Date())
        self.refresh.attributedTitle = NSAttributedString(string: " \(Fecha)")
    }
    
    
    // MARKS: Declare Refresh List
    func didRefreshList(_sender: AnyObject) {
        
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    // MARKS: Parse JSON MOVIES API
    func jsonMovies() {
        
        //let postString = "identificador=\(Identificador)";

        SVProgressHUD.show(withStatus: "Loading Movies...")
        
        Alamofire.request("http://enalcoi.info/android/webservicemuro/comments.php?identificador=\(Identificador)", method: .post).responseData { response in
            
            print("http://enalcoi.info/android/webservicemuro/comments.php?identificador=\(Identificador)")
            debugPrint("All Response Movies Info: \(String(describing: response))")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                
                // original server data as UTF8 string
                print("Data: \(utf8Text)")
                
                let responseString = String(data: data, encoding: .utf8)
                
                if ((responseString?.range(of: "1")) != nil){

                    let jsonData = JSON(response.result.value!)
                    
                    if let arrJSON = jsonData["posts"].arrayObject {
                        for index in 0...arrJSON.count-1 {
                            
                            let aObject = arrJSON[index] as! [String : AnyObject]
                            
                            let asunto = aObject["asunto"] as? String;
                            self.asuntoArray.append(asunto!)
                            
                            let fecha = aObject["fecha"] as? String;
                            self.fechaArray.append(fecha!)
                            
                            let mensaje = aObject["message"] as? String;
                            self.mensajeArray.append(mensaje!)
                            
                            let imagen = aObject["nameimagen"] as? String;
                            self.imgURLArray.append(imagen!)
                            
                            let respuesta = aObject["respuesta_administrador"] as? String;
                            self.respuestaArray.append(respuesta!)
                            
                            
                            // Print in terminal
                            print("RESPONSE: ID = \(asunto!)")
                            print("RESPONSE: TITLE = \(fecha!)")
                            print("RESPONSE: ORIGINAL TITLE = \(mensaje!)")
                            print("RESPONSE: POPULARITY = \(imagen!)")
                            print("RESPONSE: POSTER = \(respuesta!)")
                            
                        }
                    }
                    
                    SVProgressHUD.dismiss()
                    OperationQueue.main.addOperation({
                        self.tableView.reloadData()
                    })
                }

            }
            
            if((response.result.value != nil)){
                

            }
        }
    }
    
    // MARKS: Display JSON Native
    func downloadJsonWithTask() {
        
        var request = URLRequest(url: URL(string: "http://enalcoi.info/android/webservicemuro/comments.php")!)
        request.httpMethod = "POST"
        
        let postString = "identificador=\(Identificador)";
        request.httpBody = postString.data(using: .utf8)

        SVProgressHUD.show(withStatus: "Loading Messages...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            
            if ((responseString?.range(of: "1")) != nil){
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    print("MENSAJES ENVIADOS = \(jsonObj!.value(forKey: "posts")!)")
                    
                    if let messageArray = jsonObj!.value(forKey: "posts") as? NSArray {
                        for actor in messageArray{
                            
                            if let messageDictionary = actor as? NSDictionary {
                                
                                if let asunto = messageDictionary.value(forKey: "asunto") {
                                    self.asuntoArray.append(asunto as! String)
                                }
                                
                                if let fecha = messageDictionary.value(forKey: "fecha") {
                                    self.fechaArray.append(fecha as! String)
                                }
                                
                                if let message = messageDictionary.value(forKey: "message") {
                                    self.mensajeArray.append(message as! String)
                                }
                                
                                if let nameimagen  = messageDictionary.value(forKey: "nameimagen")  {
                                    self.imgURLArray.append(nameimagen as! String)
                                }
                                
                                if let respuesta_administrador  = messageDictionary.value(forKey: "respuesta_administrador")  {
                                    self.respuestaArray.append(respuesta_administrador as? String)
                                }
                            }
                        }
                    }
                     
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()

                    }
                    
                    //SVProgressHUD.dismiss()
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        
                        // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(String(describing: response))")
                    }
                }
            }
        }
        task.resume()
    }
    
    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return asuntoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.asuntoLabel.text = asuntoArray[indexPath.row]
        cell.fechaLabel.text = fechaArray[indexPath.row]
        
        if respuestaArray[indexPath.row] != nil {
            
            cell.semaforoImgView.image = UIImage(named: "semaforo-verde")
        } else {
           
            cell.semaforoImgView.image = UIImage(named: "semaforo-amarillo")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        let vc = storyboard?.instantiateViewController(withIdentifier: "VistaDetallada") as! VistaDetallada
        
        vc.nameString = asuntoArray[indexPath.row]
        vc.dobString = fechaArray[indexPath.row]
        vc.mensajeString = mensajeArray[indexPath.row]
        vc.imageString = imgURLArray[indexPath.row]
        vc.respuestaString = respuestaArray[indexPath.row] ?? ""
        
        self.present(vc, animated: true)
    }
    
    
    // MARKS: Declare Actions
    @IBAction func addBtn(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnviarMensaje") as! EnviarMensaje
        self.present(vc, animated: true)
    }
    

}
