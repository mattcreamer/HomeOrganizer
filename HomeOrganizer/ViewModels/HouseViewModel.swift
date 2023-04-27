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
    
    //TODO: Delete House Function
}
