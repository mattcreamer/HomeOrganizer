//
//  PostViewModel.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/27/23.
//

import Foundation
import FirebaseFirestore

class PostViewModel: ObservableObject {
    @Published var post = Post()
    
    func savePost(house: House, post: Post) async -> Bool {
        let db = Firestore.firestore()
        
        guard let houseID = house.id else {
            print("error with houseID")
            return false
        }
        let collectionString = "houses/\(houseID)/posts"
        
        if let id = post.id {
            do {
                try await db.collection(collectionString).document(id).setData(post.dictionary)
                print("Data updated successfully")
                return true
            } catch {
                print("Could not update data in review: \(error.localizedDescription)")
                return false
            }
        } else {
            do {
                _ = try await db.collection(collectionString).addDocument(data: post.dictionary)
                print("Data added successfully")
                return true
            } catch {
                print("Could create a new post: \(error.localizedDescription)")
                return false
            }
        }
    }
}
