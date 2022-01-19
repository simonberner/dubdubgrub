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

        VStack {
            GroupBox {
                HStack(spacing: 16) {
                    ZStack {
                        AvatarView(image: viewModel.avatar, size: 80)
                        EditImage()
                    }
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
                TextEditor(text: $viewModel.bio)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary, lineWidth: 1))
                    .focused($focusedTextField, equals: .bio)
                    .focused($dismissKeyboard)
            }
            .padding(.horizontal)

            Spacer()

            Button {
                viewModel.saveUserProfile()
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
        .onAppear(perform: {
            viewModel.getProfile()
        })
        .alert(Text(viewModel.alertItem?.title ?? ""),
               isPresented: $viewModel.showAlert) {
            Button(viewModel.alertItem?.buttonText ?? "", role: .cancel) { }
                  } message: {
                      Text(viewModel.alertItem?.message ?? "")
                  }
                  .sheet(isPresented: $viewModel.isShowingPhotoPicker) {
                      PhotoPicker(image: $viewModel.avatar)
        }
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
