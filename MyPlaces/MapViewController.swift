//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Евгений Солохин on 20.09.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIndentifier = "annotationIndentifier"
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.00
    var incomeSegueIdentifier = ""
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var adressLable: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
    
    @IBAction func centerViewInUserLocation(_ sender: Any) {
        showUserLocation()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed() {
        
    }
    
    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            adressLable.isHidden = true
            doneButton.isHidden = true
        }
        
    }
    
    
    private func setupPlacemark() {
        
        guard let location = place.location else {return}
        let geocoder       = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error{
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            let placemark        = placemarks.first
            let annotation       = MKPointAnnotation()
            annotation.title     = self.place.name
            annotation.subtitle  = self.place.type
            
            
            guard let placemarkLocation = placemark?.location else {return}
            annotation.coordinate       = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManageer()
            checkLocationAutorization()
        }else{
            //Show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(title: "Location services is not availeble",
                               message: "To give permission Go to: Settings -> My Places -> Location")
            }
        }
    }
    
    private func setupLocationManageer() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAutorization() {
        
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAdress"{ showUserLocation() }
            break
        case .denied:
            //show alert controller
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(title: "Your Location is not availeble",
                               message: "To give permission Go to: Settings -> My Places -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //show alert controller
            
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is avaliable")
        }
    }
    
    private func showUserLocation(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert    = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
        
    }
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIndentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIndentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData{
            let imageView                = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds      = true
            imageView.image              = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAutorization()
    }
}
