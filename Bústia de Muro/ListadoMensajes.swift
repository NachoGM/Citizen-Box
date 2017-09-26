//
//  ListadoMensajes.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit
import SVProgressHUD

let defaults = UserDefaults.standard
let Identificador = defaults.string(forKey: "id") ?? ""

class ListadoMensajes: UIViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addBtn(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnviarMensaje") as! EnviarMensaje
        self.present(vc, animated: true)
    }
    
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var refresh = UIRefreshControl()
    var asuntoArray = [String]()
    var fechaArray = [String]()
    var imgURLArray = [String]()
    var mensajeArray = [String]()
    var respuestaArray = [String?]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let FCMToken = defaults.string(forKey: "FCMToken") {
            print("FCM TOKEN = \(FCMToken)")
        }
        
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        self.refresh.backgroundColor = UIColor.white
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "es")
        dateformatter.setLocalizedDateFormatFromTemplate("ddMMyy hh:mm:ss")
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.medium
        
        let Fecha = dateformatter.string(from: Date())
        self.refresh.attributedTitle = NSAttributedString(string: " \(Fecha)")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = self.refresh
        
        self.downloadJsonWithTask()
        
        self.view.addSubview(tableView!)
    }
    
    
    func didRefreshList(_sender: AnyObject) {
        
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    
    func downloadJsonWithTask() {
        
        var request = URLRequest(url: URL(string: "http://enalcoi.info/android/webservicemuro/comments.php")!)
        request.httpMethod = "POST"
        
        let postString = "identificador=\(Identificador)";
        request.httpBody = postString.data(using: .utf8)
        
        SVProgressHUD.show(withStatus: "Cargando datos...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            //print("responseString = \(responseString ?? "")")
            
            if ((responseString?.range(of: "1")) != nil){
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    print("MENSAJES ENVIADOS = \(jsonObj!.value(forKey: "posts")!)")
                    
                    if let messageArray = jsonObj!.value(forKey: "posts") as? NSArray {
                        for actor in messageArray{
                            
                            if let messageDict = actor as? NSDictionary {
                                
                                if let name = messageDict.value(forKey: "asunto") {
                                    self.asuntoArray.append(name as! String)
                                }
                                
                                if let name = messageDict.value(forKey: "fecha") {
                                    self.fechaArray.append(name as! String)
                                }
                                
                                if let name = messageDict.value(forKey: "message") {
                                    self.mensajeArray.append(name as! String)
                                }
                                
                                if let name  = messageDict.value(forKey: "nameimagen")  {
                                    self.imgURLArray.append(name as! String)
                                }
                                
                                if let name  = messageDict.value(forKey: "respuesta_administrador")  {
                                    self.respuestaArray.append(name as? String)
                                }
                            }
                        }
                    }
                    
                    SVProgressHUD.dismiss()
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
 
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
}
