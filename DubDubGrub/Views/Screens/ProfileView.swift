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

    // TODO: refactor out to ProfileViewModel
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
//                saveUserProfile()
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
            getProfile()
        })
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

    // TODO: refactor out to CloudKitManager
    func saveUserProfile() {
        // Have we a valid profile?
        guard isValidProfile() else {
            showAlert = true
            alertItem = AlertContext.invalidProfileForm
            return
        }
        // Create a CKRecord from the profile data
        let profileRecord = CKRecord(recordType: RecordType.profile)
        profileRecord[DDGProfile.kFirstName] = firstName
        profileRecord[DDGProfile.kLastName] = lastName
        profileRecord[DDGProfile.kCompanyName] = companyName
        profileRecord[DDGProfile.kBio] = bio
        profileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()

        // Get the UserRecordID from the CK Container
        // TODO: refactor to us async userRecordID()
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                Logger.profileView.error("Fetching user recordID \(recordID.debugDescription) failed: \(error!.localizedDescription)")
                return
            }

            // Get the UserRecord from the CK Public Database
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    Logger.profileView.error("Fetching UserRecord failed: \(error!.localizedDescription)")
                    return
                }

                // Create a reference from the userRecord to the user profileRecord
                // action -> .deleteSelf: when the user profile gets deleted, also delete the associated profile
                // (when the parent gets deleted, also delete (my)self)
                userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)

                // Create a CKOperation to save the userRecord and profileRecord
                let operation = CKModifyRecordsOperation(recordsToSave: [userRecord, profileRecord])
                // completion block
                // (if it was successful we get savedRecords back or deletedRecords which we ignore here, otherwise an error)
                operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
                    guard let savedRecords = savedRecords, error == nil else {
                        Logger.profileView.error("Saving of userRecord and profileRecord to CloudKit failed: \(error!.localizedDescription)")
                        return
                    }

                    Logger.profileView.info("Saved records to CloudKit: \(savedRecords)")
                }

                // run the operation (to save the records)
                CKContainer.default().publicCloudDatabase.add(operation)
            }
        }
    }

    func getProfile() {
        // Get user recordID - network call to CK
        CKContainer.default().fetchUserRecordID { recordID, error in
            guard let recordID = recordID, error == nil else {
                Logger.profileView.error("Fetching user recordID \(recordID.debugDescription) failed: \(error!.localizedDescription)")
                return
            }
            // Get the UserRecord from the CK Public Database - network call to CK
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    Logger.profileView.error("Fetching UserRecord failed: \(error!.localizedDescription)")
                    return
                }

                let profileReference = userRecord["userProfile"] as! CKRecord.Reference
                let profileRecordID = profileReference.recordID

                // Get the profileRecord - network call to CK
                CKContainer.default().publicCloudDatabase.fetch(withRecordID: profileRecordID) { profileRecord, error in
                    guard let profileRecord = profileRecord, error == nil else {
                        Logger.profileView.error("Fetching profileRecord failed: \(error!.localizedDescription)")
                        return
                    }

                    // Go to the main thread and create a DDGProfile from the above profileRecord
                    // to populate the UI
                    DispatchQueue.main.async {
                        let profile = DDGProfile(record: profileRecord) // convert
                        firstName = profile.firstName
                        lastName = profile.lastName
                        companyName = profile.companyName
                        bio = profile.bio
                        avatar = profile.getImage(for: .square)
                    }
                }
            }
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
