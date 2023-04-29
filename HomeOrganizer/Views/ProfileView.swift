//
//  ProfileView.swift
//  HomeOrganizer
//
//  Created by Matt Creamer on 4/27/23.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var profileVM = ProfileViewModel()
    @State var house: House
    @State var profile: Profile
    @State private var notFilledOut = true
    @State var newProfile: Bool
    @State private var oweList: [String] = []
    @State private var dueList: [String] = []
    @State private var balanceNegative = false
    let maxDueOrOweList = 20
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if(newProfile) {
            VStack {
                Text("Welcome to Your New Profile!")
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                HStack {
                    Text("Profile Name:")
                        .bold()
                    TextField("name:", text: $profile.name)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .overlay{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray.opacity(0.5), lineWidth: 2)
                        }
                        .onChange(of: profile.name) { _ in
                            enableButtons()
                        }
                }
                
                
                HStack {
                    Text("Venmo Username:")
                        .bold()
                    TextField("venmo:", text: $profile.venmoTag)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .overlay{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray.opacity(0.5), lineWidth: 2)
                        }
                        .onChange(of: profile.venmoTag) { _ in
                            enableButtons()
                        }
                }
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let success = await profileVM.saveProfile(house: house, profile: profile)
                            if success {
                                dismiss()
                            } else {
                                print("error")
                            }
                        }
                    }
                    .disabled(notFilledOut)
                }
            }
        } else {
            VStack {
                Text(profile.name)
                    .font(.largeTitle)
                    .bold()
                HStack {
                    Text("venmo:")
                    Text("@\(profile.venmoTag)")
                }
                .font(.title)
                .bold()
                
                Rectangle()
                    .frame(maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                    .foregroundColor(.black)
                
                
                HStack {
                    VStack(alignment: .center) {
                        HStack{
                            Text("Debits: ")
                                .font(.title2)
                            Text("$\(profile.due)")
                                .font(.title3)
                        }
                        
                        List{
                            ForEach(dueList, id: \.self) { thing in
                                Text(thing)
                            }
                        }
                        .listStyle(.plain)
                        Spacer()
                    }
                    .foregroundColor(.green)
                    
                    Rectangle()
                        .frame(maxWidth: 3, maxHeight: .infinity)
                    
                    VStack(alignment: .center){
                        HStack{
                            Text("Credits: ")
                                .font(.title2)
                            Text("$\(profile.owe)")
                                .font(.title3)
                        }
                        List{
                            ForEach(oweList, id: \.self) { thing in
                                Text(thing)
                            }
                        }
                        .listStyle(.plain)
                        Spacer()
                    }
                    .foregroundColor(.red)
                }
                Rectangle()
                    .frame(maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                    .foregroundColor(.black)
                
                HStack {
                    Text("Balance:")
                    Text("$\(profile.balance)")
                }
                .foregroundColor((balanceNegative ? .red: .green))
                .font(.title)
                .bold()
                
                Spacer()
            }
            .onAppear{
                if(profile.owedString == "") {
                    oweList = ["Nothing Owed"]
                }else if(profile.owedString.count < 60) {
                    oweList = [profile.owedString.replacingOccurrences(of: ",", with: "")]
                } else {
                    oweList = profile.owedString.split(separator: ",").map{String($0)}
                }
                if(profile.dueString == ""){
                    dueList = ["Nothing Due"]
                } else if(profile.dueString.count < 50) {
                    dueList = [profile.dueString.replacingOccurrences(of: ",", with: "")]
                } else {
                    dueList = profile.dueString.split(separator: ",").map{String($0)}
                    
                }
                let balanceValue = Double(profile.balance)
                if(balanceValue! < 0) {
                    balanceNegative = true
                }
                else {
                    balanceNegative = false
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                            Text("Back to Posts")
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }
    
    func enableButtons() {
        let nameIsGood = profile.name.count >= 1
        let venmoIsGood = profile.venmoTag.count >= 1
        profile.balance = "0"
        profile.due = "0"
        profile.owe = "0"
        notFilledOut = !(nameIsGood && venmoIsGood)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(house: House(name: "Club Kirk"), profile: Profile(), newProfile: true)
        }
        
    }
}
