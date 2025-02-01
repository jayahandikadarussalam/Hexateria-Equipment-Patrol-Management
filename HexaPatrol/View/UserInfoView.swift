//
//  UserInfoView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @State private var searchText = ""
    let user: User?
    
    let plantData: PlantData = PlantData(plantID: 1, plantName: "Plant 1", areaData: [
        AreaData(areaID: 1, areaName: "Area 1", equipmentGroup: [
            EquipmentGroup(equipmentGroupID: 1, equipmentGroupName: "Group 1", equipmentType: [
                EquipmentType(equipmentTypeID: 1, equipmentTypeName: "Type 1", tagno: [
                    Tagno(tagnoID: 1, tagnoName: "Tag 1", parameter: [
                        Parameter(parameterID: 1, parameterName: "Parameter 1", unit: "Unit", formType: "Type", booleanOption: "True", correctOption: "Correct", gap: "Gap", mandatory: .bool(true), min: nil, max: nil, ordering: 1)
                    ])
                ])
            ])
        ])
    ])
    
    var body: some View {
        TabView {
            // Home Tab
            HomeTabView( user: user)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            //MARK: ActivityTab
//            ActivityView(viewModel:viewModel)
//            .tabItem {
//                Image(systemName: "chart.line.uptrend.xyaxis")
//                Text("Activity")
//            }

            //MARK: History Tab
            NavigationStack {
                VStack {
                    Spacer()
                        .font(.title)
                    // Add content for History tab here
                }
                .navigationTitle("History")
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            }
            .tabItem {
                Image(systemName: "clock.fill")
                Text("History")
            }

            //MARK: User Details Tab
            NavigationStack {
                UserDetailsView(user: user)
                    .navigationTitle("Me")
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Me")
            }
        }
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().standardAppearance = tabBarAppearance
        }
    }
}

#Preview {
    UserInfoView(user: nil)
        .environmentObject(AuthViewModel())
        .environmentObject(CameraViewModel())
}
