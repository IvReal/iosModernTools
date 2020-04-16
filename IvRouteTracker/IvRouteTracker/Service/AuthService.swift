//
//  AuthService.swift
//  IvRouteTracker
//
//  Created by Iv on 16.04.2020.
//  Copyright © 2020 Iv. All rights reserved.
//

import RealmSwift

class User : Object {
    @objc dynamic var login: String = ""
    @objc dynamic var password: String = ""
    
    override static func primaryKey() -> String? {
        return "login"
    }
}

class AuthService
{
    static let instance = AuthService()
    private init() {}
    
    func registerUser(login: String, password: String) -> Bool {
        let user = User(value: [login, password])
        do {
            let realm = try Realm()
            realm.beginWrite()
            realm.add(user, update: .all)
            try realm.commitWrite()
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func checkUser(login: String, password: String) -> Bool {
        var res = false
        do {
            let realm = try Realm()
            let users = Array(realm.objects(User.self).filter("login = '\(login)' AND password = '\(password)'"))
            res = users.count > 0
        } catch {
            print(error)
        }
        return res
    }
}
