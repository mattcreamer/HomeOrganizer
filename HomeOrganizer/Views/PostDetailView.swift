//
//  PostDetailView.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/27/23.
//

import SwiftUI
import Firebase
import PhotosUI

struct PostDetailView: View {
    @StateObject var postVM = PostViewModel()
    @StateObject var profileVM = ProfileViewModel()
    @State var house: House
    @State var post: Post
    @State var profile: Profile
    @State var postedByThisUser = false
    @State var postedByString = "Create Your Post:"
    @State var chosenCategory: Category = .Grocery
    @State private var doubleAlertShowing = false
    @State private var alertString = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var postImage = Image(systemName: "note.text.badge.plus")
    @State private var imageURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    enum Category: String, Codable, CaseIterable {
            case Grocery
            case Entertainment
            case Cleaning
            case Misc
        }
    
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Spacer()
                
                if imageURL != nil {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom)
                    } placeholder: {
                        Image(systemName: "note.text.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    postImage
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom)
                }
                Spacer()
            }
            
            
            if(post.id == nil) {
                HStack {
                    Spacer()
                    
                    PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                        Label("Add Photo From Library", systemImage: "photo.fill.on.rectangle.fill")
                    }
                    .onChange(of: selectedPhoto) { newValue in
                        Task{
                            do {
                                if let data = try await newValue?.loadTransferable(type: Data.self){
                                    if let uiImage = UIImage(data: data){
                                        postImage = Image(uiImage: uiImage)
                                        imageURL = nil
                                    }
                                }
                            } catch {
                                print("ERROR: Loading Failed \(error.localizedDescription)")
                            }
                        }
                    }
                    Spacer()
                }
            }
            
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                .foregroundColor(.black)
            
        
            Text("\(postedByString)")
            
            
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
                    .keyboardType(.numbersAndPunctuation)
            }
            HStack {
                Text("Category:")
                Picker("", selection: $chosenCategory) {
                    ForEach(Category.allCases, id: \.self) { cat in
                        Text(cat.rawValue)
                    }
                }
                .onChange(of: chosenCategory) { _ in
                    post.category = chosenCategory.rawValue
                }
                .pickerStyle(.wheel)
            }
            
            Text("Comments:")
            TextField("Tap Here to Comment!", text: $post.comments, axis: .vertical)
                .padding(.horizontal, 6)
                .frame(maxHeight: 200, alignment: .topLeading)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray.opacity(0.5), lineWidth: post.id == nil ? 2 : 0)
                }
        }
        .font(.title2)
        .bold()
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .onAppear {
            if post.poster == Auth.auth().currentUser?.email {
                postedByThisUser = true
            } else {
                let postPostedOn = post.postedOn.formatted(.dateTime.day().month().year())
                postedByString = "by: \(post.poster) on: \(postPostedOn)"
            }
            Task {
                if let url = await postVM.getImageURL(post: post) {
                    imageURL = url
                }
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
                        if Double(post.cost) != nil {
                            Task {
                                await profileVM.dividingPostCosts(house: house, post: post, profile: profile, currUser: (Auth.auth().currentUser?.email ?? ""), currUserVenmo: profile.venmoTag)
                                let success = await postVM.savePost(house: house, post: post)
                                if success {
                                    await postVM.saveImage(post: post, image: ImageRenderer(content: postImage).uiImage ?? UIImage())
                                    dismiss()
                                } else {
                                    print("error")
                                }
                            }
                        } else {
                            alertString = "Item's Cost Must be inputted as a Double"
                            doubleAlertShowing.toggle()
                        }
                        
                    }
                }
                if post.id != nil {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        
                        Button {
                            Task {
                                let success = await postVM.deletePost(house: house, post: post)
                                if success {
                                    dismiss()
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
        
        .alert(alertString, isPresented: $doubleAlertShowing) {
            Button("OK", role: .cancel) {}
        }
        
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PostDetailView(house: House(name: "Club Kirk", address: "62 Kirkwood Rd", tenants: "10"), post: Post(), profile: Profile())
        }
        
    }
}
