//
//  Localizacion.swift
//  Bústia de Muro
//
//  Created by Nacho MAC on 29/8/17.
//  Copyright © 2017 Ajuntament de Muro. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Localizacion: UIViewController, CLLocationManagerDelegate {

    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    let location = CLLocationManager()
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        
        let Localizacion = ("\(location.coordinate.latitude), \(location.coordinate.longitude)")
        UserDefaults.standard.set(Localizacion, forKey: "localizacion");
        UserDefaults.standard.synchronize();
        
        mapView.showsUserLocation = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
        location.requestWhenInUseAuthorization()
        location.startUpdatingLocation()
    }

}
