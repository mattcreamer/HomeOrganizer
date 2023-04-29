//
//  Profile.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/27/23.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Profile: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var email = Auth.auth().currentUser?.email ?? ""
    var name = ""
    var venmoTag = ""
    var due = ""
    var owe = ""
    var balance = ""
    var owedString = ""
    var dueString = ""
    
    var dictionary: [String: Any] {
        return ["email": email, "name": name, "venmoTag": venmoTag, "due": due, "owe": owe, "balance": balance, "owedString": owedString, "dueString": dueString]
    }
    
}
