//
//  LocationDetailView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 21.12.21.
//

import SwiftUI

struct LocationDetailView: View {

    // @ObservedObject: to tell SwiftUI we want to watch the object for changes
    // but don’t own it directly. -> The object is passed in from the LocationListView!
    // (https://www.hackingwithswift.com/quick-start/swiftui/whats-the-difference-between-observedobject-state-and-environmentobject)
    @ObservedObject var viewModel: LocationDetailViewModel

    var body: some View {
        VStack(spacing: 16) {
            BannerImageView(image: viewModel.location.getImage(for: .banner))

            HStack {
                AddressView(address: viewModel.location.address)
                
                Spacer()
            }
            .padding(.horizontal)

            DescriptionView(text: viewModel.location.description)

            GroupBox {
                HStack(spacing: 20) {
                    Button {
                        viewModel.getDirectionsToLocation()
                    } label: {
                        LocationActionButton(color: .brandPrimary, imageName: "location.fill")
                    }

                    Link(destination: URL(string: viewModel.location.websiteURL)!, label: {
                        LocationActionButton(color: .brandPrimary, imageName: "network")
                    })

                    Button {
                        viewModel.callLocation()
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

            ScrollView {
                // only 10 views can be placed in the grid
                LazyVGrid(columns: viewModel.columns, content: {
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                    FirstNameAvatarView(image: PlaceholderImage.avatar, firstName: "Simon")
                })
            }
            Spacer()
        }
        .alert(Text(viewModel.alertItem?.title ?? ""),
               isPresented: $viewModel.showAlert) {
            Button(viewModel.alertItem?.buttonText ?? "", role: .cancel) { }
                  } message: {
                      Text(viewModel.alertItem?.message ?? "")
                  }
        .navigationTitle(viewModel.location.name)
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

    var image: UIImage
    var firstName: String

    var body: some View {
        VStack {
            AvatarView(image: image, size: 64)

            Text(firstName)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

struct BannerImageView: View {

    var image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 120)
    }
}

struct AddressView: View {

    var address: String

    var body: some View {
        Label(address, systemImage: "mappin.and.ellipse")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

struct DescriptionView: View {

    var text: String

    var body: some View {
        Text(text)
            .lineLimit(3)
            .minimumScaleFactor(0.75)
            .frame(height: 70)
            .padding(.horizontal)
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Tip: Put the Preview into a NavigationView to see how it looks like
        NavigationView {
            LocationDetailView(viewModel: LocationDetailViewModel(location: DDGLocation(record: MockData.location)))
        }
    }
}
