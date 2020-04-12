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

    /* current location example
    @IBAction func currentLocation(_ sender: Any) {
        locationManager?.requestLocation()
    }*/
    
    @IBAction func startTrack(_ sender: Any) {
        clearRoute() // Отвязываем от карты старую линию
        route = GMSPolyline() // Заменяем старую линию новой
        routePath = GMSMutablePath() // Заменяем старый путь новым, пока пустым (без точек)
        route?.map = mapView // Добавляем новую линию на карту
        locationManager?.startUpdatingLocation() // Запускаем отслеживание или продолжаем, если оно уже запущено
        locationManager?.startMonitoringSignificantLocationChanges()
    }
    
    @IBAction func finishTrack(_ sender: Any) {
        locationManager?.stopUpdatingLocation() // Останавливаем отслеживание
        locationManager?.stopMonitoringSignificantLocationChanges()
        writeTrackToDb() // Записываем трек в БД
    }
    
    @IBAction func showRoute(_ sender: Any) {
        clearRoute()
        loadTrackFromDbAndShow()
    }
    
    let initCoordinate = CLLocationCoordinate2D(latitude: 59.925, longitude: 30.463) // СПб
    var locationManager: CLLocationManager?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var prevRoute: GMSPolyline?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
    }

    private func configureMap() {
        mapView.delegate = self
        gotoLocation(coordinate: initCoordinate, withAnimate: false)
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
    }

    private func gotoLocation(coordinate: CLLocationCoordinate2D, withAnimate: Bool) {
        if withAnimate {
            mapView.animate(toLocation: coordinate)
        } else {
            mapView.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        }
    }
    
    private func addMarker(coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        //marker.icon = GMSMarker.markerImage(with: .green)
        //marker.title = "My place"
        //marker.snippet = "Now I'm here"
        marker.map = mapView
    }
    
    private func writeTrackToDb() {
        guard let route = routePath else { return }
        var points: [TrackPoint] = []
        for i in 0...route.count() - 1 {
            let tp = TrackPoint()
            tp.id = Int(i + 1)
            tp.lat = route.coordinate(at: i).latitude
            tp.lon = route.coordinate(at: i).longitude
            points.append(tp)
        }
        RouteService.instance.removeRouteFromDb()
        RouteService.instance.addRouteToDb(points)
    }
    
    private func loadTrackFromDbAndShow() {
        let points = RouteService.instance.loadTrackPointArrayFromDb()
        let path = GMSMutablePath()
        for point in points {
            path.add(CLLocationCoordinate2D(latitude: point.lat, longitude: point.lon))
        }
        prevRoute = GMSPolyline(path: path)
        prevRoute?.map = mapView
        let bounds = GMSCoordinateBounds(coordinate: path.coordinate(at: 0), coordinate: path.coordinate(at: path.count() - 1))
        let camera = mapView.camera(for: bounds, insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))!
        mapView.camera = camera
    }
    
    private func clearRoute() {
        route?.map = nil
        prevRoute?.map = nil
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        /* add marker example
         let marker = GMSMarker(position: coordinate)
         marker.map = mapView*/
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        /* markers path example
         gotoLocation(coordinate: location.coordinate, withAnimate: true)
         addMarker(coordinate: location.coordinate)*/
        /* geocoder example
         let geocoder = CLGeocoder()
         geocoder.reverseGeocodeLocation(location) { places, error in
            print(places?.first)
         }*/
        routePath?.add(location.coordinate) // Добавляем точку в путь маршрута
        route?.path = routePath // Обновляем путь у линии маршрута путём повторного присвоения
        // Чтобы наблюдать за движением, установим камеру на только что добавленную точку
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: position)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
