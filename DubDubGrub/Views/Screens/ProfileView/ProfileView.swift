//
//  ProfileView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI
import CloudKit
import OSLog

struct ProfileView: View {

    @FocusState private var focusedTextField: ProfileTextField?
    @FocusState private var dismissKeyboard: Bool

    @StateObject private var viewModel = ProfileViewModel()

    enum ProfileTextField {
    case firstname, lastname, companyName, bio
    }

    var body: some View {

        ZStack{
            VStack {
                GroupBox {
                    HStack(spacing: 16) {

                        ProfileImageView(image: viewModel.avatar)
                            .onTapGesture {
                                viewModel.isShowingPhotoPicker = true
                            }

                        VStack(spacing: 1) {
                            TextField("First Name", text: $viewModel.firstName)
                                .profileNameStyle()
                                .focused($focusedTextField, equals: .firstname)
                                .onSubmit { focusedTextField = .lastname }
                                .submitLabel(.next)

                            TextField("Last Name", text: $viewModel.lastName)
                                .profileNameStyle()
                                .focused($focusedTextField, equals: .lastname)
                                .onSubmit { focusedTextField = .companyName }
                                .submitLabel(.next)

                            TextField("Company Name", text: $viewModel.companyName)
                                .focused($focusedTextField, equals: .companyName)
                                .onSubmit { focusedTextField = .bio }
                                .submitLabel(.next)
                        }
                        .focused($dismissKeyboard)
                        .padding(.trailing, 16)

                        Spacer()
                    }
                }
                .cornerRadius(12)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {

                    HStack {
                        CharacterRemainView(currentCount: viewModel.bio.count)
                            .accessibilityAddTraits(.isHeader)

                        Spacer()

                        if viewModel.isCheckedIn {
                            Button {
                                viewModel.checkOut()
                            } label: {
                                CheckOutButton()
                            }
                            .disabled(viewModel.isLoading)
                        }
                    }

                    BioTextEditor(text: $viewModel.bio, focusedTextField: $focusedTextField, dismissKeyboard: $dismissKeyboard)
                }
                .padding(.horizontal)

                Spacer()

                Button {
                    viewModel.determineButtonAction()
                } label: {
                    DDGButton(title: viewModel.buttonTitle)
                        .padding()
                }
            }

            if viewModel.isLoading {LoadingView()}
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(DeviceTypes.isiPhone8Standard ? .inline : .automatic)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button {
                        dismissKeyboard.toggle()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundColor(.brandPrimary)
                    }
                }
            }
        }
        .onAppear(perform: {
            // We call this func everytime the Profile view is tapped. This is good enough for an MVP
            // and we don't go any deeper down the rabbit hole do find a better solution (eg. a CK
            // subscription to the profile data)
            viewModel.getProfile()
            viewModel.getCheckedInStatus()
        })
        .alert(Text(viewModel.alertItem?.title ?? ""),
               isPresented: $viewModel.showAlert) {
            Button(viewModel.alertItem?.buttonText ?? "", role: .cancel) { }
                  } message: {
                      Text(viewModel.alertItem?.message ?? "")
                  }
                  .sheet(isPresented: $viewModel.isShowingPhotoPicker) { PhotoPicker(image: $viewModel.avatar) }
    }
}

fileprivate struct ProfileImageView: View {

    var image: UIImage

    var body: some View {
        ZStack {
            AvatarView(image: image, size: 80)

            Image(systemName: "square.and.pencil")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(.white)
                .offset(y: 30)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("Profile Photo"))
        .accessibilityHint(Text("Opens the iPhone's photo picker"))
    }
}

fileprivate struct CharacterRemainView: View {

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

struct CheckOutButton: View {

    var body: some View {
        Label("Check Out", systemImage: "mappin.and.ellipse")
            .font(.system(size: 12, weight: .semibold))
            .frame(width: 100, height: 26)
            .background(Color.grubRed)
            .foregroundColor(.white)
            .cornerRadius(8)
            .accessibilityLabel(Text("Check out of the current location"))
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}

struct BioTextEditor: View {

    var text: Binding<String>
    var focusedTextField: FocusState<ProfileView.ProfileTextField?>.Binding
    var dismissKeyboard: FocusState<Bool>.Binding

    var body: some View {
        TextEditor(text: text)
            .frame(height: 100)
            .overlay { RoundedRectangle(cornerRadius: 10).stroke(Color.secondary, lineWidth: 1) }
            .focused(focusedTextField, equals: ProfileView.ProfileTextField.bio)
            .focused(dismissKeyboard)
            .accessibilityHint(Text("This TextField is for your bio and has a 100 character maximum."))
    }
}
