//
//  Protected.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class Protected: UIViewController {

    
    // MARKS: Declare Outlets
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var nombreUser: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutBtn.layer.cornerRadius = 20
        
        let defaults = UserDefaults.standard
        let userFB = defaults.string(forKey: "name") ?? ""
        let idFB = defaults.string(forKey: "id") ?? ""
        let FBprofileImage = NSURL (string: "https://graph.facebook.com/\(idFB)/picture?type=large")! as URL
        
        if let data = NSData(contentsOf: FBprofileImage) {
            imgProfile.image = UIImage(data: data as Data)
        }
        
        nombreUser.text = userFB
    }
    
    // MARKS: Declare Actions
    @IBAction func logoutBtn(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Inicio") as! Inicio
        self.present(vc, animated: true)
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListadoMensajes") as! ListadoMensajes
        self.present(vc, animated: true)
    }
    
    




}
