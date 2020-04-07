//
//  ViewController.swift
//  IvRouteTracker
//
//  Created by Iv on 06.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MainMapView!

    @IBAction func currentLocation(_ sender: Any) {
        locationManager?.requestLocation()
    }
    
    @IBAction func updateLocation(_ sender: Any) {
        locationManager?.startUpdatingLocation()
    }
    
    let initCoordinate = CLLocationCoordinate2D(latitude: 59.925, longitude: 30.463) // СПб
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
    }

    private func configureMap() {
        mapView.delegate = self
        gotoLocation(coordinate: initCoordinate, withAnimate: false)
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
    }

    func gotoLocation(coordinate: CLLocationCoordinate2D, withAnimate: Bool) {
        if withAnimate {
            mapView.animate(toLocation: coordinate)
        } else {
            mapView.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        }
    }
    
    func addMarker(coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        //marker.icon = GMSMarker.markerImage(with: .green)
        //marker.title = "My place"
        //marker.snippet = "Now I'm here"
        marker.map = mapView
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        /*let marker = GMSMarker(position: coordinate)
        marker.map = mapView*/
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        gotoLocation(coordinate: location.coordinate, withAnimate: true)
        addMarker(coordinate: location.coordinate)
        /*let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { places, error in
            print(places?.first)
        }*/
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
