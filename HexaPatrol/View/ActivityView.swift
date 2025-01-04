//
//  ActivityView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 01/01/25.
//


import SwiftUI

struct ActivityView: View {
    @State private var searchText = ""
    @ObservedObject var viewModel: AuthViewModel
    @State private var isRefreshing = false
    
    var filteredPlantData: [PlantData] {
        if searchText.isEmpty {
            return viewModel.plants
        } else {
            return viewModel.plants.filter { plant in
                plant.plantName.localizedCaseInsensitiveContains(searchText) ||
                plant.areaData.contains { area in
                    area.areaName.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredPlantData, id: \.plantID) { plant in
                Section(header: Text("Plant: \(plant.plantName)").font(.subheadline)) {
                    ForEach(plant.areaData, id: \.areaID) { area in
                        NavigationLink(destination: AreaDetailView(area: area)) {
                            VStack(alignment: .leading) {
                                Text("Area: \(area.areaName)")
                                    .font(.headline)
                                
                                ForEach(area.equipmentGroup, id: \.equipmentGroupID) { group in
                                    Text("Equipment Group: \(group.equipmentGroupName)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Activity")
            .overlay {
                if isRefreshing {
                    ProgressView()
                }
            }
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        // Call the refresh function from viewModel
        print("Refreshing data...")
        await viewModel.refreshHirarkiData()
        print("Data refreshed:", viewModel.plants)
    }
    
    // Area Detail View
    struct AreaDetailView: View {
        let area: AreaData
        
        var body: some View {
            List {
                ForEach(area.equipmentGroup, id: \.equipmentGroupID) { group in
                    Section(header: Text("Equipment Group: \(group.equipmentGroupName)").font(.subheadline)) {
                        ForEach(group.equipmentType, id: \.equipmentTypeID) { type in
                            NavigationLink(destination: EquipmentTypeDetailView(equipmentType: type)) {
                                Text(type.equipmentTypeName)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Area \(area.areaName)")
        }
    }
    
    // Equipment Type Detail View
    struct EquipmentTypeDetailView: View {
        let equipmentType: EquipmentType
        
        var body: some View {
            List {
                ForEach(equipmentType.tagno, id: \.tagnoID) { tag in
                    Section(header: Text("Tagno: \(tag.tagnoName)").font(.subheadline)) {
                        ForEach(tag.parameter, id: \.parameterID) { param in
                            ParameterRow(parameter: param)
                        }
                    }
                }
            }
            .navigationTitle(equipmentType.equipmentTypeName)
        }
    }
    
    // Parameter Row View
    struct ParameterRow: View {
        let parameter: Parameter
        
        // Helper function to convert Mandatory enum to Bool
        private func isMandatory(_ mandatory: Mandatory) -> Bool {
            switch mandatory {
            case .int(let value):
                return value != 0
            case .bool(let value):
                return value
            }
        }
        
        // Helper function to get formatted value range
        private func getValueRange() -> String {
            var rangeComponents: [String] = []

            // Tampilkan min jika ada, dan max jika ada, tapi jangan tampilkan keduanya jika salah satunya tidak ada
            if let min = parameter.min, min != 0 {
                rangeComponents.append("Min: \(min)")
            }
            if let max = parameter.max, max != 0 {
                rangeComponents.append("Max: \(max)")
            }

            return rangeComponents.joined(separator: ", ")
        }

        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(parameter.parameterName)
                        .font(.headline)
                    if isMandatory(parameter.mandatory) {
                        Text("*")
                            .foregroundColor(.red)
                            .font(.headline)
                    }
                }
                
                if !parameter.unit.isEmpty {
                    Text("Unit: \(parameter.unit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                let range = getValueRange()
                if !range.isEmpty {
                    Text(range)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !parameter.formType.isEmpty {
                    Text("Type: \(parameter.formType)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !parameter.booleanOption.isEmpty {
                    Text("Boolean Options: \(parameter.booleanOption)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !parameter.gap.isEmpty {
                    Text("Gap: \(parameter.gap)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(viewModel: MockAuthViewModel())
            .environmentObject(MockAuthViewModel())
    }
}
