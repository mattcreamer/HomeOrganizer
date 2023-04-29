//
//  HouseDetailView.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/26/23.
//

import SwiftUI
import Firebase
import PhotosUI

struct HouseDetailView: View {
    @EnvironmentObject var houseVM: HouseViewModel
    @State var house: House
    @State private var showingAsSheet = false
    @State private var showingAlert = false
    @State private var enterPortalSheet = false
    @State private var inputtedPassword = ""
    @State private var maxTenants: Int = 50
    @State private var passwordString = "Password Incorrect: Please Try Again"
    @State private var postedWithUser = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var houseImage = Image(systemName: "house")
    @State private var imageURL: URL?
    var previewRunning = false
    
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading) {
            Group(){
                if(house.id == nil) {
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
                                            houseImage = Image(uiImage: uiImage)
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
                
                if imageURL != nil {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom)
                    } placeholder: {
                        Image(systemName: "house")
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    houseImage
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom)
                }
                
                
                Rectangle()
                    .frame(maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                    .foregroundColor(.black)
                
                Text("House Name:")
                TextField("House Name:", text: $house.name)
                    .textFieldStyle(.roundedBorder)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: house.id == nil ? 2 : 0)
                    }
                    .foregroundColor(house.id == nil ? .black : .gray)
                
                Text("House Address:")
                TextField("House Address:", text: $house.address)
                    .textFieldStyle(.roundedBorder)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: house.id == nil ? 2 : 0)
                    }
                    .foregroundColor(house.id == nil ? .black : .gray)
            }
            .disabled(house.id == nil ? false : true)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .font(.title2)
            .bold()
            
            Group{
                if house.id == nil {
                    Text("Number of Tenants:  ")
                    TextField("Tenants:", text: $house.tenants)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .overlay{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray.opacity(0.5), lineWidth: house.id == nil ? 2 : 0)
                        }
                        
                        
                    Text("Create Password: ") //add a ***** or see password function
                    TextField("Must be 6 characters to Save:", text: $house.housePassword)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                        .overlay{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray.opacity(0.5), lineWidth: house.id == nil ? 2 : 0)
                        }
                        .foregroundColor(.accentColor)
                }
                else {
                    VStack {
                        HStack {
                            Text("Number of Tenants: ")
                            Text("\(house.tenants)")
                                .foregroundColor(.gray)
                                
                            Spacer()
                        }
                        Rectangle()
                            .frame(maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                            .foregroundColor(.accentColor)
                        
                        HStack {
                            Text("Enter Password: ")
                            TextField("password", text: $inputtedPassword)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .textFieldStyle(.roundedBorder)
                        }
                        .foregroundColor(.accentColor)
                        .tint(.accentColor)
                    }
                }
            }
            .font(.title2)
            .bold()
            
            Spacer()
            
            HStack {
                Spacer()
                if(house.id != nil) {
                    Button("Enter \(house.name)'s Portal") {
                        if inputtedPassword == house.housePassword {
                            enterPortalSheet.toggle()
                        } else {
                            inputtedPassword = ""
                            showingAlert.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
                Spacer()
            }
        }
        .padding()
        .task {
            if let id = house.id {
                if let url = await houseVM.getImageURL(id: id) {
                    imageURL = url
                }
            }
        }
        .onAppear {
            if !previewRunning && house.id != nil {
                print("Preview is Running error")
            } else {
                showingAsSheet = true
            }
            if house.creator == Auth.auth().currentUser?.email {
                postedWithUser = true
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(house.id == nil)
        .toolbar{
            if showingAsSheet {
                if house.id == nil && showingAsSheet {
                    ToolbarItem(placement: .cancellationAction){
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button("Save") {
                            if(Double(house.tenants) != nil) {
                                Task {
                                    let success = await houseVM.saveHouse(house: house)
                                    if success {
                                        await houseVM.saveImage(id: house.id ?? "", image: ImageRenderer(content: houseImage).uiImage ?? UIImage())
                                        dismiss()
                                    } else {
                                        print("Dang error in saving spot")
                                    }
                                }
                            } else {
                                passwordString = "Tenants Must be Inputted in a Numerical Form"
                                showingAlert.toggle()
                            }
                        }
                        .disabled(house.housePassword.count >= 6 ? false : true)
                    }
                } else if showingAsSheet && house.id != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            if(house.id != nil && postedWithUser) {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            let success = await houseVM.deleteHouse(house: house)
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
        .alert(passwordString, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $enterPortalSheet) {
            PostScrollView(house: house)
        }
    }
}


struct HouseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HouseDetailView(house: House())
                .environmentObject(HouseViewModel())
        }
    }
}
