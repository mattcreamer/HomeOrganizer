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
    //@State var post: Post
    //@StateObject var postVM = PostViewMoodel()
    @FirestoreQuery(collectionPath: "houses") var posts: [Post]
    
    @State private var postSheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    var previewRunning = false
    var body: some View {
        NavigationStack {
            List(posts) { post in
                NavigationLink {
                    //PostDetailView
                } label: { //want picture of item involved in this
                    HStack {
                        Text("\(post.item) bought by \(post.name)")
                    }
                    //style the list
                    
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
                        //TODO: Profile View
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                    }
                    .tint(.accentColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        postSheetIsPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $postSheetIsPresented) {
            NavigationStack {
                PostDetailView(house: house, post: Post())
            }
        }
    }
}

struct PostScrollView_Previews: PreviewProvider {
    static var previews: some View {
        PostScrollView(house: House(name: "Club Kirk", address: "62 Kirkwood Rd", tenants: "10"), previewRunning: true)
    }
}
