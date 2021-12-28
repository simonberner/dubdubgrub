//
//  ProfileView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI

struct ProfileView: View {

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
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.white)
                            .offset(y: 30)
                    }

                    VStack(spacing: 1) {
                        TextField("First Name", text: $firstName)
                            .font(.system(size: 32, weight: .bold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)

                        TextField("Last Name", text: $lastName)
                            .font(.system(size: 32, weight: .bold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)

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
                    Text("Bio: ")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    +
                    Text("\(100 - bio.count)")
                        .bold()
                        .font(.callout)
                        .foregroundColor(bio.count <= 100 ? .brandPrimary : Color(.systemPink))
                    +
                    Text(" characters remaining")
                        .font(.callout)
                        .foregroundColor(.secondary)

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
                Text("Create Profile")
                    .bold()
                    .frame(width: 280, height: 44)
                    .background(Color.brandPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

        }
        .navigationTitle("Profile")
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
