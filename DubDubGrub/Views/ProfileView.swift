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

            HStack {
                Text("Bio: 95 characters remaining")
                    .fontWeight(.light)
                Button {

                } label: {
                    Label("Check Out", systemImage: "mappin.and.ellipse")
                }
                .accessibilityIdentifier("CheckOut")
            }

            TextField("Description", text: .constant("test"))
                .padding()
                .frame(height: 200)

            Spacer()


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
