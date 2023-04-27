//
//  PostDetailView.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/27/23.
//

import SwiftUI
import Firebase

struct PostDetailView: View {
    @StateObject var postVM = PostViewModel()
    @State var house: House
    @State var post: Post
    @State var postedByThisUser = false
    @State var postedByString = "Create Your Post:"
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading){
            Image(systemName: "rosette")
                .resizable()
                .scaledToFit()
            HStack {
                Text("\(postedByString)")
            }
            
            HStack {
                Text("Item Name:")
                TextField("Item Name:", text: $post.item)
                    .textFieldStyle(.roundedBorder)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: post.id == nil ? 2 : 0)
                    }
            }
            HStack {
                Text("Cost:")
                TextField("Cost:", text: $post.cost)
                    .textFieldStyle(.roundedBorder)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: post.id == nil ? 2 : 0)
                    }
            }
            
            
            HStack {
                Text("Category:")
                Picker("", selection: $post.category) {
                    ForEach(Post.Category.allCases, id: \.self) { cat in
                        Text(cat.rawValue)
                    }
                }
            }
            Text("Comments:")
            TextField("Comments:", text: $post.comments, axis: .vertical)
                .padding(.horizontal, 6)
                .frame(maxHeight: 200, alignment: .topLeading)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray.opacity(0.5), lineWidth: post.id == nil ? 2 : 0)
                }
        }
        .onAppear {
            if post.poster == Auth.auth().currentUser?.email {
                postedByThisUser = true
            } else {
                let postPostedOn = post.postedOn.formatted(date: .numeric, time: .omitted)
                postedByString = "by: \(post.poster) on: \(postPostedOn)"
            }
        }
        .padding()
        .disabled(!postedByThisUser)
        .navigationBarBackButtonHidden(postedByThisUser)
        .toolbar {
            if postedByThisUser {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let success = await postVM.savePost(house: house, post: post)
                            if success {
                                dismiss()
                            } else {
                                print("error")
                            }
                        }
                    }
                }
                if post.id != nil {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        
                        Button {
                            Task {
                                /*let success = await reviewVM.deleteReview(spot: spot, review: review)
                                if success {
                                    dismiss()
                                }*/
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
        
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PostDetailView(house: House(name: "Club Kirk", address: "62 Kirkwood Rd", tenants: "10"), post: Post())
        }
        
    }
}
