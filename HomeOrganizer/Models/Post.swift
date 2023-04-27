//
//  Post.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/27/23.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Post: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var item = ""
    var poster = Auth.auth().currentUser?.email ?? ""
    var name = ""
    var cost = ""
    var category: Category = Category.Misc
    var comments = ""
    var postedOn = Date()
    
    enum Category: String, Codable, CaseIterable {
        case Grocery
        case Entertainment
        case Cleaning
        case Misc
    }
    
    var dictionary: [String: Any] {
        return ["item": item, "poster": poster, "name": name, "cost": cost, "category": category, "comments": comments, "postedOn": Timestamp(date: Date())]
    }
    
}
