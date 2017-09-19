//
//  Instrucciones.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit

class Instrucciones: UIViewController {

    

    @IBAction func understoodBtn(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Inicio") as! Inicio
        self.navigationController?.pushViewController(vc, animated: true)
    }


}
