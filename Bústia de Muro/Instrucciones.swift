//
//  Instrucciones.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit
import SwiftyOnboard

class Instrucciones: UIViewController {


    @IBOutlet weak var paso1: UIView!
    @IBOutlet weak var paso2: UIView!
    @IBOutlet weak var paso3: UIView!
    @IBOutlet weak var paso4: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paso1.layer.cornerRadius = 10
        paso2.layer.cornerRadius = 10
        paso3.layer.cornerRadius = 10
        paso4.layer.cornerRadius = 10

    }

    @IBAction func understoodBtn(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Inicio") as! Inicio
        self.navigationController?.pushViewController(vc, animated: true)
    }


}
