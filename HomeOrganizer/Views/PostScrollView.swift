//
//  HouseDetailView.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/27/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct PostScrollView: View {
    @State var house: House
    @FirestoreQuery(collectionPath: "houses") var posts: [Post]
    @StateObject var profileVM = ProfileViewModel()
    @State private var returnHomeSheetIsPresented = false
    @State private var postSheetIsPresented = false
    @State private var createProfileSheetIsPresented = false
    @State private var profileSheetIsPresented = false
    @State private var userHasProfile = false
    @State private var showingAlert = false
    @State private var alertMsg = "You Must Create a Profile First"
    @State var userProfile = Profile()
    
    @Environment(\.dismiss) private var dismiss
    var previewRunning = false
    var body: some View {
        NavigationStack {
            List(posts) { post in
                NavigationLink {
                    PostDetailView(house: house, post: post, profile: userProfile)
                } label: {
                    HStack {
                        Text("\(post.item) bought by \(post.poster)")
                            .font(.title2)
                            .bold()
                    }
                }
            }
            .listStyle(.plain)
            .onAppear {
                if !previewRunning && house.id != nil {
                    $posts.path = "houses/\(house.id ?? "")/posts"
                }
            }
            .navigationTitle("Recent Posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        returnHomeSheetIsPresented.toggle()
                    } label: {
                        Image(systemName: "chevron.left")
                        Text("Return Home")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if(!userHasProfile) {
                            createProfileSheetIsPresented.toggle()
                        } else {
                            profileSheetIsPresented.toggle()
                        }
                    } label: {
                        Text(userHasProfile ? "\(userProfile.name)" : "New Profile")
                        Image(systemName: "person.crop.circle.fill")
                    }
                    .tint(.accentColor)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            if(!userHasProfile) {
                                showingAlert.toggle()
                            } else {
                                postSheetIsPresented.toggle()
                            }
                            
                        } label: {
                            HStack {
                                Text("Create New Post")
                                Image(systemName: "plus")
                            }
                            
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    }
                    .padding()
                }
            }
        }
        .alert(alertMsg, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        
        .onAppear{
            Task {
                userHasProfile = await profileVM.existingProfiles(house: house, currUser: (Auth.auth().currentUser?.email ?? ""))
                userProfile = await profileVM.userProfile(house: house, currUser: (Auth.auth().currentUser?.email ?? ""))
            }
        }
        .sheet(isPresented: $postSheetIsPresented, onDismiss: {
            Task {
                userProfile = await profileVM.userProfile(house: house, currUser: (Auth.auth().currentUser?.email ?? ""))
            }
        }, content: {
            NavigationStack {
                PostDetailView(house: house, post: Post(), profile: userProfile)
            }
        })
        .sheet(isPresented: $createProfileSheetIsPresented, onDismiss: {
            Task {
                userHasProfile = await profileVM.existingProfiles(house: house, currUser: (Auth.auth().currentUser?.email ?? ""))
                userProfile = await profileVM.userProfile(house: house, currUser: (Auth.auth().currentUser?.email ?? ""))
            }
        }, content: {
            NavigationStack {
                ProfileView(house: house, profile: userProfile, newProfile: true)
            }
        })
        
        .fullScreenCover(isPresented: $profileSheetIsPresented) {
            NavigationStack {
                ProfileView(house: house, profile: userProfile, newProfile: false)
            }
        }
        .fullScreenCover(isPresented: $returnHomeSheetIsPresented) {
            HouseScrollView()
        }
    }
}

struct PostScrollView_Previews: PreviewProvider {
    static var previews: some View {
        PostScrollView(house: House(name: "Club Kirk", address: "62 Kirkwood Rd", tenants: "10"), previewRunning: true)
    }
}
