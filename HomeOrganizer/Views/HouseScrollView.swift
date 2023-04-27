//
//  HouseSelectorView.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/26/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct HouseScrollView: View {
    @FirestoreQuery(collectionPath: "houses") var houses: [House]
    @State private var  houseSheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(houses) { house in
                NavigationLink {
                    HouseDetailView(house: house)
                }label: {
                    Text(house.name)
                        .font(.title2)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Available Houses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Log Out") {
                        do {
                            try Auth.auth().signOut()
                            print("Log Out Successful")
                            dismiss()
                        } catch {
                            print("Could not sign out")
                        }
                    }
                    .tint(.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        houseSheetIsPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    
                    Button {
                        //TODO: Need a Search Function - search for houses in list !!!
                    } label: {
                        Image(systemName: "magnifyingglass.circle.fill")
                    }
                    
                }
            }
            .tint(.accentColor)
            .sheet(isPresented: $houseSheetIsPresented) {
                NavigationStack {
                    HouseDetailView(house: House())
                }
            }
        }
    }
}

struct HouseScrollView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HouseScrollView()
        }
    }
}
