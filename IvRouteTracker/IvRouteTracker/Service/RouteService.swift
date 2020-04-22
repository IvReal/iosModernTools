//
//  RouteService.swift
//  IvRouteTracker
//
//  Created by Iv on 12.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import RealmSwift

class TrackPoint : Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lon: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class RouteService
{
    static let instance = RouteService()
    private init() {}
    
    func addRouteToDb(_ track: [TrackPoint]) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            for point in track {
                realm.add(point)
            }
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func removeRouteFromDb() {
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.delete(realm.objects(TrackPoint.self))
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }

    func loadTrackPointArrayFromDb() -> [TrackPoint] {
        do {
            let realm = try Realm()
            //print(realm.configuration.fileURL)
            return Array(realm.objects(TrackPoint.self))
        } catch {
            print(error)
            return []
        }
    }
}
