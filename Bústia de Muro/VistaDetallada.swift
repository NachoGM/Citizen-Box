//
//  VistaDetallada.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit
import SVProgressHUD

class VistaDetallada: UIViewController {
    
    // MARKS: Declare Outlets
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var titularLabel: UILabel!
    @IBOutlet weak var mensajeLabel: UILabel!
    @IBOutlet weak var respuestaLabel: UILabel!
    
    // MARKS: Declare var
    var dobString:String!
    var nameString:String!
    var mensajeString:String!
    var respuestaString:String!
    var imageString:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // Load Info
        self.updateUI()
        
        // Load Admin Answer
        if (respuestaString.isEmpty == true) {
            
            self.respuestaLabel.text = "Ninguna respuesta por parte del administrador."
        } else {
            
            self.respuestaLabel.text = respuestaString ?? ""
        }
        
    }
    
    
    // MARKS: Update info
    func updateUI() {
        
        self.titularLabel.text = nameString ?? ""
        self.fechaLabel.text = dobString ?? ""
        self.mensajeLabel.text = mensajeString ?? ""
        
        let StringURL = "\("http://enalcoi.info/android/galeria_usuarios/")\(imageString!)"
        
        let imgURL = URL(string:StringURL)
        
        let data = NSData(contentsOf: (imgURL)!)
        self.myImageView.image = UIImage(data: data! as Data)
    }
    
    
    // MARKS: Declare Actions
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
