//
//  AppTabView.swift
//  DubDubGrub
//
//  Created by Simon Berner on 20.12.21.
//

import SwiftUI

struct AppTabView: View {

    @StateObject var viewModel = AppTabViewModel()

    var body: some View {
        TabView {
            LocationMapView()
                .tabItem { Label("Map", systemImage: "map") }

            LocationListView()
                .tabItem { Label("Locations", systemImage: "building") }

            NavigationView { ProfileView() }
            .tabItem { Label("Profile", systemImage: "person") }

        }
        .task { // cancels the network call automatically when the user navigates away from the view
            try? await CloudKitManager.shared.getUserRecord() // try? -> just nil in case of an error
            viewModel.checkIfHasSeenOnboardView()
        }
        .sheet(isPresented: $viewModel.isShowingOnboardView) {
            // closure the returns the content of the sheet
            OnboardView()
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
