//
//  HouseDetailView.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/26/23.
//

import SwiftUI

struct HouseDetailView: View {
    @EnvironmentObject var houseVM: HouseViewModel
    @State var house: House
    @State private var showingAsSheet = false
    @State private var showingAlert = false
    @State private var enterPortalSheet = false
    @State private var inputtedPassword = ""
    @State private var maxTenants: Int = 50
    @State private var passwordString = "Password Incorrect: Please Try Again"
    
    var previewRunning = false // Check video on this
    
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading) {
            Group(){
                Image(systemName: "house")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom)
                
                Text("House Name:")
                TextField("House Name:", text: $house.name)
                    .textFieldStyle(.roundedBorder)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: house.id == nil ? 2 : 0)
                    }
                
                Text("House Address:")
                TextField("House Address:", text: $house.address)
                    .textFieldStyle(.roundedBorder)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: house.id == nil ? 2 : 0)
                    }
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
                        .textFieldStyle(.roundedBorder)
                        .overlay{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray.opacity(0.5), lineWidth: house.id == nil ? 2 : 0)
                        }
                    
                    Text("Create Password: ") //add a ***** or see password function
                    TextField("Must be 6 characters to Save:", text: $house.housePassword)
                        .textFieldStyle(.roundedBorder)
                        .overlay{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray.opacity(0.5), lineWidth: house.id == nil ? 2 : 0)
                        }
                }
                else {
                    VStack {
                        HStack {
                            Text("Number of Tenants: \(house.tenants)")
                            Spacer()
                        }
                        Rectangle()
                            .frame(maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                            .foregroundColor(.accentColor)
                        
                        HStack {
                            Text("Enter Password: ")
                            TextField("password", text: $inputtedPassword)
                                .textFieldStyle(.roundedBorder)
                        }
                        .foregroundColor(.accentColor)
                        .tint(.accentColor)
                    }
                }
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
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
        } //end VStack
        .padding()
        .onAppear {
            if !previewRunning && house.id != nil {
                print("Preview is Running error")
            } else {
                showingAsSheet = true
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
                            Task {
                                let success = await houseVM.saveHouse(house: house)
                                if success {
                                    dismiss()
                                } else {
                                    print("Dang error in saving spot")
                                }
                            }
                            dismiss()
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
        }
        .alert(passwordString, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $enterPortalSheet) {
            PostScrollView(house: house) //, post: Post())
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
