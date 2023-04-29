//
//  PostViewModel.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/27/23.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

@MainActor
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
    func deletePost(house: House, post: Post) async -> Bool {
        let db = Firestore.firestore()
        guard let houseID = house.id, let postID = post.id else {
            print("Null IDs - error")
            return false
        }
        
        do {
            let _ = try await db.collection("houses").document(houseID).collection("posts").document(postID).delete()
            return true
        } catch {
            print("Null IDs - error: \(error.localizedDescription)")
            return false
        }
    }
    func saveImage(post: Post, image: UIImage) async {
        if let id = post.id {
            let storage = Storage.storage()
            let storageRef = storage.reference().child("\(id)/image.jpg")
            
            let resizedImage = image.jpegData(compressionQuality: 0.2)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            if let resizedImage = resizedImage {
                do {
                    let metadata = try await storageRef.putDataAsync(resizedImage)
                    print("Metadata: ", metadata)
                    print("Image Saved!")
                } catch {
                    print("ERROR: uploading image to FirebaseStorage \(error.localizedDescription)")
                }
            }
        }
        else {
            return
        }
    }
    
    func getImageURL(post: Post) async -> URL? {
        
        if let id = post.id {
            let storage = Storage.storage()
            let storageRef = storage.reference().child("\(id)/image.jpg")
            
            do {
                let url = try await storageRef.downloadURL()
                return url
            } catch {
                return nil
            }
        }
        else {
            return nil
        }
    }
}
