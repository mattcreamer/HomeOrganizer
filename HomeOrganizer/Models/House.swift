//
//  House.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/26/23.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct House: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name = ""
    var housePassword = ""
    var address = ""
    var tenants = ""
    var creator = Auth.auth().currentUser?.email ?? ""
    var imageID = ""
    
    var dictionary: [String: Any] {
        return ["name": name, "housePassword": housePassword, "address": address, "tenants": tenants, "creator": creator, "imageID": imageID]
    }
    
}
