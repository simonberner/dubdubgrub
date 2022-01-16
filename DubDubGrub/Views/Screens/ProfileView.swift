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
    @State private var avatar = PlaceholderImage.avatar
    @State private var isShowingPhotoPicker = false
    @State private var alertItem: AlertItem?
    @State private var showAlert = false

    @FocusState private var focusedTextField: ProfileTextField?
    @FocusState private var dismissKeyboard: Bool

    enum ProfileTextField {
    case firstname, lastname, companyName, bio
    }

    var body: some View {

        VStack {
            GroupBox {
                HStack(spacing: 16) {
                    ZStack {
                        AvatarView(image: avatar, size: 80)
                        EditImage()
                    }
                    .onTapGesture {
                        isShowingPhotoPicker = true
                    }

                    VStack(spacing: 1) {
                        TextField("First Name", text: $firstName)
                            .profileNameStyle()
                            .focused($focusedTextField, equals: .firstname)
                            .onSubmit { focusedTextField = .lastname }
                            .submitLabel(.next)

                        TextField("Last Name", text: $lastName)
                            .profileNameStyle()
                            .focused($focusedTextField, equals: .lastname)
                            .onSubmit { focusedTextField = .companyName }
                            .submitLabel(.next)

                        TextField("Company Name", text: $companyName)
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

                // Bio Text - 100 characters limited
                TextEditor(text: $bio)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary, lineWidth: 1))
                    .focused($focusedTextField, equals: .bio)
                    .focused($dismissKeyboard)
            }
            .padding(.horizontal)


            Spacer()

            Button {
                createProfile()
            } label: {
                DDGButton(title: "Create Profile")
                    .padding()
            }

        }
        .navigationTitle("Profile")
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
        .alert(Text(alertItem?.title ?? ""),
               isPresented: $showAlert) {
            Button(alertItem?.buttonText ?? "", role: .cancel) { }
                  } message: {
                      Text(alertItem?.message ?? "")
                  }
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPicker(image: $avatar)
        }
    }

    func isValidProfile() -> Bool {

        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !companyName.isEmpty,
              !bio.isEmpty,
              avatar != PlaceholderImage.avatar,
              bio.count <= 100 else { return false }
        
        return true
    }

    func createProfile() {
        guard isValidProfile() else {
            showAlert = true
            alertItem = AlertContext.invalidProfileForm
            return
        }
        // create profile and send it up to CloudKit
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
