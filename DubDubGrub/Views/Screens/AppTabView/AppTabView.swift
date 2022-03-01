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
        .onAppear {
            CloudKitManager.shared.getUserRecord()
            viewModel.runStartupChecks()
        }
        .sheet(isPresented: $viewModel.isShowingOnboardView, onDismiss: viewModel.checkLocationServicesIsEnabled) {
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
