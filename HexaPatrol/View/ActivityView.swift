//
//  ActivityView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 01/01/25.
//

import SwiftUI

struct ActivityView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var searchText = ""
    @State private var isRefreshing = false
    @State private var refreshSuccess = false
    @Namespace private var topID
    
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
            ScrollViewReader { scrollProxy in // Store ScrollViewReader's proxy
                List(filteredPlantData, id: \.plantID) { plant in
                    Section(header: Text("Plant: \(plant.plantName)")
                        .font(.subheadline)
                        .id(topID)
                    ) {
                        ForEach(plant.areaData, id: \.areaID) { area in
                            NavigationLink(destination: AreaDetailView(area: area)) {
                                VStack(alignment: .leading) {
                                    Text("Area: \(area.areaName)")
                                        .font(.headline)
                                        .navigationTitle("Activity")
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
                    // Use the scrollProxy from the ScrollViewReader's closure
                    await refreshData()
                    withAnimation {
                        scrollProxy.scrollTo(topID, anchor: .top)
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .overlay {
                    if isRefreshing {
                        ProgressView()
                    }
                }
                .alert("Data Refreshed Successfully", isPresented: $refreshSuccess) {
                    Button("OK", role: .cancel) { }
                }
            }
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        await viewModel.refreshHirarkiData()
        print("Data refreshed:", viewModel.plants)
        
        refreshSuccess = true
    }
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
        @State private var expandedSections: Set<Int> = []
        
        var body: some View {
//            List {
//                ForEach(equipmentType.tagno, id: \.tagnoID) { tag in
//                    Section(header: Text("Tagno: \(tag.tagnoName)").font(.subheadline)) {
//                        ForEach(tag.parameter, id: \.parameterID) { param in
//                            ParameterRow(parameter: param)
//                        }
//                    }
//                }
//            }
            List {
                ForEach(equipmentType.tagno, id: \.tagnoID) { tag in
                    Section(header: sectionHeader(for: tag)) {
                        if expandedSections.contains(tag.tagnoID) {
                            ForEach(tag.parameter, id: \.parameterID) { param in
                                ParameterRow(parameter: param)
                            }
                        }
                    }
                }
            }
            .navigationTitle(equipmentType.equipmentTypeName)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Expand All") {
                            expandedSections = Set(equipmentType.tagno.map { $0.tagnoID })
                        }
                        Button("Collapse All") {
                            expandedSections.removeAll()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        
        
        private func sectionHeader(for tag: Tagno) -> some View {
            HStack {
                Text("Tagno: \(tag.tagnoName)")
                    .font(.subheadline)
//                    .foregroundColor(.blue)
                Spacer()
                Button(action: {
                    toggleSection(tagID: tag.tagnoID)
                }) {
                    Image(systemName: expandedSections.contains(tag.tagnoID) ? "chevron.down" : "chevron.right")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        
        private func toggleSection(tagID: Int) {
            if expandedSections.contains(tagID) {
                expandedSections.remove(tagID)
            } else {
                expandedSections.insert(tagID)
            }
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
                
                Group {
                    if !parameter.unit.isEmpty {
                        Text("Unit: \(parameter.unit)")
                    }
                    let range = getValueRange()
                    if !range.isEmpty {
                        Text(range)
                    }
                    if !parameter.formType.isEmpty {
                        Text("Type: \(parameter.formType)")
                    }
                    if !parameter.booleanOption.isEmpty {
                        Text("Boolean Options: \(parameter.booleanOption)")
                    }
                    if !parameter.gap.isEmpty {
                        Text("Gap: \(parameter.gap)")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 2)
        }
    }

#Preview {
    ActivityView(viewModel: MockAuthViewModel())
        .environmentObject(MockAuthViewModel())
}

