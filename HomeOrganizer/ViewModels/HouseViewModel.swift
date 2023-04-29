//
//  HouseViewModel.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/26/23.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit


@MainActor
class HouseViewModel: ObservableObject {
    @Published var house = House()
    
    func saveHouse(house: House) async -> Bool {
        let db = Firestore.firestore()
        
        if let id = house.id {
            do {
                try await db.collection("houses").document(id).setData(house.dictionary)
                print("Data updated successfully")
                return true
            } catch {
                print("Could not update data in house: \(error.localizedDescription)")
                return false
            }
        } else {
            do {
                let documentRef = try await db.collection("houses").addDocument(data: house.dictionary)
                self.house = house
                self.house.id = documentRef.documentID
                print("Data added successfully")
                return true
            } catch {
                print("Could create a new house: \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func deleteHouse(house: House) async -> Bool {
        let db = Firestore.firestore()
        
        if let id = house.id {
            do {
                try await db.collection("houses").document(id).delete()
                return true
            } catch {
                print("error deleting")
                return false
            }
        }
        return false
    }
    
    
    func saveImage(id: String, image: UIImage) async {
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
    
    func getImageURL(id: String) async -> URL? {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(id)/image.jpg")
        
        do {
            let url = try await storageRef.downloadURL()
            return url
        } catch {
            return nil
        }
        
    }
}
