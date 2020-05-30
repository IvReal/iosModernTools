//
//  ViewController.swift
//  IvRouteTracker
//
//  Created by Iv on 06.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift

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
        locationManager.startUpdatingLocation() // Запускаем отслеживание или продолжаем, если оно уже запущено
    }
    
    @IBAction func finishTrack(_ sender: Any) {
        locationManager.stopUpdatingLocation() // Останавливаем отслеживание
        writeTrackToDb() // Записываем трек в БД
    }
    
    @IBAction func getPhoto(_ sender: Any) {
        // Load Route from Db example
        //clearRoute()
        //loadTrackFromDbAndShow()
        
        // Проверка, поддерживает ли устройство камеру
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        // Создаём контроллер и настраиваем его
        let imagePickerController = UIImagePickerController()
        // Источник изображений: камера
        imagePickerController.sourceType = .camera
        // Изображение можно редактировать
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        // Показываем контроллер
        present(imagePickerController, animated: true)
    }
    
    let initCoordinate = CLLocationCoordinate2D(latitude: 59.925, longitude: 30.463) // СПб
    let locationManager = LocationManager.instance
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    var prevRoute: GMSPolyline?
    let disposeBag = DisposeBag()
    let marker: GMSMarker = GMSMarker()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
    }

    private func configureMap() {
        gotoLocation(coordinate: initCoordinate, withAnimate: false)
        marker.map = mapView
    }
        
    func configureLocationManager() {
        locationManager
            .location
            .asObservable()
            .bind { [weak self] location in
                guard let location = location else { return }
                self?.routePath?.add(location.coordinate)
                self?.route?.path = self?.routePath // Обновляем путь у линии маршрута путём повторного присвоения
                // Чтобы наблюдать за движением, установим камеру на только что добавленную точку
                let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
                self?.marker.position = location.coordinate
                self?.mapView.animate(to: position)
            }
            .disposed(by: disposeBag)
    }

    private func gotoLocation(coordinate: CLLocationCoordinate2D, withAnimate: Bool) {
        if withAnimate {
            mapView.animate(toLocation: coordinate)
        } else {
            mapView.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        }
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

extension MapViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // закрытие UIImagePickerController по отмене
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // закрываем UIImagePickerController
            picker.dismiss(animated: true) { [weak self] in
                // после того, как он закроется, извлечём изображение
                guard let image = self?.extractImage(from: info) else { return }
                let imview = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                imview.image =  image
                imview.layer.cornerRadius = imview.frame.size.width / 2
                imview.clipsToBounds = true
                self?.marker.iconView = imview

            }
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey : Any]) -> UIImage? {
        // отредактированное изображение
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            return image
        }
        // оригинальное изображение
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            return image
        }
        return nil
    }
}

/* location manager delegate example
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
}*/
