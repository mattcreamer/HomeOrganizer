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
    @State private var searchText = ""
    @State private var logOut = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(houseResults) { house in
                NavigationLink {
                    HouseDetailView(house: house)
                }label: {
                    Text(house.name)
                        .font(.title2)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Available Houses")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Log Out") {
                        do {
                            try Auth.auth().signOut()
                            print("Log Out Successful")
                            logOut.toggle()
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
            }
            .tint(.accentColor)
            .sheet(isPresented: $houseSheetIsPresented) {
                NavigationStack {
                    HouseDetailView(house: House())
                }
            }
            .fullScreenCover(isPresented: $logOut) {
                NavigationStack {
                    LoginView()
                }
            }
        }
    }
    var houseResults: [House] {
        if searchText.isEmpty {
            return houses
        } else {
            return houses.filter{$0.name.contains(searchText)}
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
