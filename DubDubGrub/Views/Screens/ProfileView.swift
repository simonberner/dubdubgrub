//
//  ProfileView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI

struct ProfileView: View {

    // TODO: these will go into the view model later on
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var companyName = ""
    @State private var bio = ""

    var body: some View {

        VStack {
            GroupBox {
                HStack(spacing: 16) {
                    ZStack {
                        AvatarView(size: 80)
                        EditImage()
                    }

                    VStack(spacing: 1) {
                        TextField("First Name", text: $firstName)
                            .profileNameStyle()

                        TextField("Last Name", text: $lastName)
                            .profileNameStyle()

                        TextField("Company Name", text: $companyName)
                    }
                    .padding(.trailing, 16)


                    Spacer()
                }
            }
            .cornerRadius(12)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    CharacterRemainView(currentCount: bio.count)

                    Spacer()

                    Button {

                    } label: {
                        Label("Check Out", systemImage: "mappin.and.ellipse")
                            .font(.callout)
                            .frame(width: 125, height: 30)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                TextEditor(text: $bio)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary, lineWidth: 1))
            }
            .padding(.horizontal)


            Spacer()

            Button {

            } label: {
                DDGButton(title: "Create Profile")
            }

        }
        .navigationTitle("Profile")
        
    }
}

struct EditImage: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .scaledToFit()
            .frame(width: 14, height: 14)
            .foregroundColor(.white)
            .offset(y: 30)
    }
}

struct CharacterRemainView: View {

    var currentCount: Int

    var body: some View {
        Text("Bio: ")
            .font(.callout)
            .foregroundColor(.secondary)
        +
        Text("\(100 - currentCount)")
            .bold()
            .font(.callout)
            .foregroundColor(currentCount <= 100 ? .brandPrimary : Color(.systemPink))
        +
        Text(" characters remaining")
            .font(.callout)
            .foregroundColor(.secondary)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
