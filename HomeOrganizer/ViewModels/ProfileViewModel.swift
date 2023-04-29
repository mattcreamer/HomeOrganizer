//
//  ProfileViewModel.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/27/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile = Profile()
    
    func saveProfile(house: House, profile: Profile) async -> Bool {
        let db = Firestore.firestore()
        
        guard let houseID = house.id else {
            print("error with houseID")
            return false
        }
        let collectionString = "houses/\(houseID)/profiles"
        
        if let id = profile.id {
            do {
                try await db.collection(collectionString).document(id).setData(profile.dictionary)
                print("Data updated successfully")
                return true
            } catch {
                print("Could not update data in review: \(error.localizedDescription)")
                return false
            }
        } else {
            do {
                _ = try await db.collection(collectionString).addDocument(data: profile.dictionary)
                print("Data added successfully")
                return true
            } catch {
                print("Could create a new profile: \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func existingProfiles(house: House, currUser: String) async -> Bool {
        let db = Firestore.firestore()
        var idList: [String] = []
        guard let houseID = house.id else {
            print("error with houseID")
            return false
        }
        let collectionString = "houses/\(houseID)/profiles"
        do {
            let returnCollection = try await db.collection(collectionString).getDocuments()
            for document in returnCollection.documents {
                idList.append(document.documentID)
            }
        } catch {
            return false
        }
        
        for availId in idList {
            do {
                let document = try await db.collection(collectionString).document(availId).getDocument().data()
                if(((document?["email"]) ?? "") as! String == currUser) {
                    return true
                }
            } catch {
                print("error with each docucment: \(error.localizedDescription)")
                return false
            }
        }
        return false
    }
    
    func userProfile(house: House, currUser: String) async -> Profile {
        let db = Firestore.firestore()
        var idList: [String] = []
        guard let houseID = house.id else {
            print("error with houseID")
            return Profile()
        }
        let collectionString = "houses/\(houseID)/profiles"
        do {
            let returnCollection = try await db.collection(collectionString).getDocuments()
            for document in returnCollection.documents {
                idList.append(document.documentID)
            }
        } catch {
            return Profile()
        }
        
        for availId in idList {
            do {
                let document = try await db.collection(collectionString).document(availId).getDocument().data()
                if(((document?["email"]) ?? "") as! String == currUser) {
                    return Profile(email: ((document?["email"]) ?? "") as! String, name: ((document?["name"]) ?? "") as! String, venmoTag: ((document?["venmoTag"]) ?? "") as! String, due: ((document?["due"]) ?? "") as! String, owe: ((document?["owe"]) ?? "") as! String, balance: ((document?["balance"]) ?? "") as! String, owedString: ((document?["owedString"]) ?? "") as! String, dueString: ((document?["dueString"]) ?? "") as! String)
                }
            } catch {
                print("error with each docucment: \(error.localizedDescription)")
                return Profile()
            }
        }
        return Profile()
    }
    
    func dividingPostCosts(house: House, post: Post, profile: Profile, currUser: String, currUserVenmo: String) async {
        let db = Firestore.firestore()
        var idList: [String] = []
        guard let houseID = house.id else {
            print("error with houseID")
            return
        }
        let collectionString = "houses/\(houseID)/profiles"
        do {
            let returnCollection = try await db.collection(collectionString).getDocuments()
            for document in returnCollection.documents {
                idList.append(document.documentID)
            }
        } catch {
            print("error getting documents: \(error.localizedDescription)")
            return
        }
        
        guard let totalCost: Double = Double(post.cost) else {return}
        guard let houseTenants: Double = Double(house.tenants) else {return}
        let individualCost = totalCost / houseTenants
        
        for availId in idList {
            do{
                let document = try await db.collection(collectionString).document(availId).getDocument().data()
                if((document?["email"] ?? "") as! String == currUser) {
                    let newDueString = "\(profile.dueString)You are owed $\(totalCost) for \(post.item),"
                    guard let dueFigure: Double = Double(profile.due) else {return}
                    guard let owedFigure: Double = Double(profile.owe) else {return}
                    let newDueFigure = dueFigure + totalCost
                    let newBalanceFigure = "\(newDueFigure - owedFigure)"
                    
                    try await db.collection(collectionString).document(availId).setData(["email": profile.email, "name": profile.name, "venmoTag": profile.venmoTag, "due": "\(newDueFigure)", "owe": profile.owe, "balance": newBalanceFigure, "owedString": profile.owedString, "dueString": newDueString])
                        
                }
                else {
                    let newOweString = "\(((document?["owedString"]) ?? "") as! String)Venmo @\(currUserVenmo) $\(individualCost) for \(post.item),"
                    guard let oweFigure: Double = Double(((document?["owe"]) ?? "") as! String) else {return}
                    guard let dueFigure: Double = Double(((document?["due"]) ?? "") as! String) else {return}
                    let newOweFigure = oweFigure + individualCost
                    let newBalanceFigure = "\(dueFigure - newOweFigure)"
                    
                    try await db.collection(collectionString).document(availId).setData(["email": ((document?["email"]) ?? "") as! String, "name": ((document?["name"]) ?? "") as! String, "venmoTag": ((document?["venmoTag"]) ?? "") as! String, "due": ((document?["due"]) ?? "") as! String, "owe": "\(newOweFigure)", "balance": newBalanceFigure, "owedString": newOweString, "dueString": ((document?["dueString"]) ?? "") as! String])
                }
            }
            catch {
                print("error on first document collection: \(error.localizedDescription)")
                return
            }
            
        }
    }
}
