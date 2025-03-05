//
//  UserInfoView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject var viewModel: APIService
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @State private var searchText = ""
    @State private var selectedTab = 0
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
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeTabView(selectedTab: $selectedTab, user: user)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            //MARK: ActivityTab
//            ActivityView(viewModel:viewModel)
//            .tabItem {
//                Image(systemName: "chart.line.uptrend.xyaxis")
//                Text("Activity")
//            }

            //MARK: History Tab
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Image(systemName: "clock.fill")
                Text("History")
            }
            .tag(1)

            //MARK: User Details Tab
            NavigationStack {
                UserDetailsView(user: user)
                    .navigationTitle("Me")
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Me")
            }
            .tag(2)
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
        .environmentObject(APIService())
        .environmentObject(CameraViewModel())
}
