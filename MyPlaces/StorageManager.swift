//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Евгений Солохин on 14.09.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager{
    
    static func saveObject(_ place: Place){
        
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place){
        
        try! realm.write{
            realm.delete(place)
        }
    }
}
