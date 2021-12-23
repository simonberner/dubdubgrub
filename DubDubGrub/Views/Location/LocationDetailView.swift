//
//  LocationDetailView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 21.12.21.
//

import SwiftUI

struct LocationDetailView: View {

    // TODO: refactor this into a view model
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Image("default-banner-asset")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                HStack {
                    Label("123 Main Street", systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.horizontal)

                Text("This is a test description. This is a test description. This is a test description. This is a test description. ")
                    .lineLimit(3)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal)

                GroupBox {
                    HStack(spacing: 20) {
                        Button {

                        } label: {
                            LocationActionButton(color: .brandPrimary, imageName: "location.fill")
                        }

                        Link(destination: URL(string: "https://www.apple.com")!, label: {
                            LocationActionButton(color: .brandPrimary, imageName: "network")
                        })

                        Button {

                        } label: {
                            LocationActionButton(color: .brandPrimary, imageName: "phone.fill")
                        }

                        Button {

                        } label: {
                            LocationActionButton(color: .brandPrimary, imageName: "person.fill.xmark")
                        }
                    }

                }
                .foregroundColor(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 60, style: .continuous))
                .padding(.horizontal)

                Text("Who's here?")
                    .bold()
                    .font(.title2)

                // only 10 views can be placed in the grid
                LazyVGrid(columns: columns, content: {
                    FirstNameAvatarView(firstName: "Simon")
                    FirstNameAvatarView(firstName: "Simon")
                    FirstNameAvatarView(firstName: "Simon")
                    FirstNameAvatarView(firstName: "Simon")
                    FirstNameAvatarView(firstName: "Simon")
                    FirstNameAvatarView(firstName: "Simon")
                    FirstNameAvatarView(firstName: "Simon")
                    FirstNameAvatarView(firstName: "Simon")
                    FirstNameAvatarView(firstName: "Simon")
                })

                Spacer()
            }
        }
        .navigationTitle("Location Name")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// as long this button is only used inside this view, it
// can stay here
struct LocationActionButton: View {

    var color: Color
    var imageName: String

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
                .frame(width: 60, height: 60)
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
        }
    }
}

struct FirstNameAvatarView: View {

    var firstName: String

    var body: some View {
        VStack {
            AvatarView(size: 64)

            Text(firstName)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView()
    }
}

