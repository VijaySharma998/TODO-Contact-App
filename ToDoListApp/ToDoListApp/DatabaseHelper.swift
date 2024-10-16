//
//  DatabaseHelper.swift
//  ToDoListApp
//
//  Created by Vijay Sharma on 16/10/24.
//

import UIKit
import RealmSwift

class DatabaseHelper {
    static let shared = DatabaseHelper()
    
    private let realm = try! Realm()
    
    func getDatabaseURL() -> URL? {
        //use the capital c for Configuration to access the defaultConfiguration
        return Realm.Configuration.defaultConfiguration.fileURL
    }
    
    func saveContact(_ contact: Contact) {
        try! realm.write {
            realm.add(contact)
        }
    }
    func getContact() -> [Contact] {
        return Array(realm.objects(Contact.self))
    }
    func deleteContact(_ contact: Contact) {
        try! realm.write {
            realm.delete(contact)
        }
    }
    func updateContact(oldContact: Contact, newContact: Contact) {
        try! realm.write {
            oldContact.firstName = newContact.firstName
            oldContact.lastName = newContact.lastName
        }
    }
}
