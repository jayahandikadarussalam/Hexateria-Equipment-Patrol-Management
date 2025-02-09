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
    @State private var showToast = false
    @Namespace private var topID
    
    let user: User?
    
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
            ScrollViewReader { scrollProxy in
                List(filteredPlantData, id: \.plantID) { plant in
                    Section(header: PlantSectionHeader(plantName: plant.plantName, topID: topID)) {
                        ForEach(plant.areaData, id: \.areaID) { area in
                            NavigationLink(destination: AreaDetailView(area: area)) {
                                AreaRowView(area: area)
                            }
                        }
                    }
                }
                .refreshable {
                    await refreshData(scrollProxy: scrollProxy)
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .overlay(alignment: .top) {
                    if showToast {
                        ToastView(message: "Data Refreshed Successfully")
                            .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Activity")
            .navigationBarBackButtonHidden(user?.role == "operator")
        }
    }
    
    private func refreshData(scrollProxy: ScrollViewProxy) async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            
            await viewModel.refreshHirarkiData()
            
            withAnimation {
                showToast = true
                scrollProxy.scrollTo(topID, anchor: .top)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showToast = false
                }
            }
        } catch {
            print("Failed to refresh: \(error)")
        }
    }
}

// MARK: - Supporting Views
struct PlantSectionHeader: View {
    let plantName: String
    let topID: Namespace.ID
    
    var body: some View {
        Text("Plant: \(plantName)")
            .font(.subheadline)
            .id(topID)
    }
}

struct AreaRowView: View {
    let area: AreaData
    
    var body: some View {
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

struct ToastView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .padding()
            .background(Color.green.opacity(0.8))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 5)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Area Detail View
struct AreaDetailView: View {
    @State private var searchText = ""
    let area: AreaData

    var filteredEquipmentGroups: [EquipmentGroup] {
        if searchText.isEmpty {
            return area.equipmentGroup
        } else {
            return area.equipmentGroup.filter { group in
                group.equipmentGroupName.localizedCaseInsensitiveContains(searchText) ||
                group.equipmentType.contains { type in
                    type.equipmentTypeName.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }

    var body: some View {
        List {
            ForEach(filteredEquipmentGroups, id: \.equipmentGroupID) { group in
                Section(header: Text("Equipment Group: \(group.equipmentGroupName)").font(.subheadline)) {
                    ForEach(group.equipmentType.filter { type in
                        searchText.isEmpty || type.equipmentTypeName.localizedCaseInsensitiveContains(searchText)
                    }, id: \.equipmentTypeID) { type in
                        NavigationLink(destination: EquipmentTypeDetailView(equipmentType: type)) {
                            Text(type.equipmentTypeName)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Area \(area.areaName)")
    }
}

// MARK: - Equipment Type Detail View
struct EquipmentTypeDetailView: View {
    let equipmentType: EquipmentType
    @Environment(\.colorScheme) var colorScheme
    @State private var expandedSections: Set<Int> = []
    @State private var completionPercentage: Double = 0
    @State private var searchText = ""
    
    // Filtered Tagno
    var filteredTagno: [Tagno] {
        if searchText.isEmpty {
            return equipmentType.tagno
        } else {
            return equipmentType.tagno.filter { tagno in
                tagno.tagnoName.localizedCaseInsensitiveContains(searchText) ||
                tagno.parameter.contains { parameter in
                    parameter.parameterName.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Equipment Completion: \(Int(completionPercentage * 100))%")
                .font(.headline)
                .padding(.horizontal)
            
            ProgressView(value: completionPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: equipmentProgressBarColor))
                .frame(height: 10)
                .padding(.horizontal)
            
            // Pass filtered data to TagnoListView
            TagnoListView(
                equipmentType: EquipmentType(
                    equipmentTypeID: equipmentType.equipmentTypeID,
                    equipmentTypeName: equipmentType.equipmentTypeName,
                    tagno: filteredTagno
                ),
                expandedSections: $expandedSections,
                onCompletionChanged: { updateEquipmentCompletion() }
            )
        }
        .padding(.vertical)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle(equipmentType.equipmentTypeName)
        .onAppear {
            updateEquipmentCompletion()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ExpandCollapseMenu(
                    equipmentType: equipmentType,
                    expandedSections: $expandedSections
                )
            }
        }
        .navigationBarBackButtonHidden(UserDefaults.standard.string(forKey: "role") == "Operator")
        .background(
            (colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .edgesIgnoringSafeArea(.all)
        )
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func updateEquipmentCompletion() {
        completionPercentage = calculateEquipmentCompletionPercentage()
    }
    
    private func calculateEquipmentCompletionPercentage() -> Double {
        guard !equipmentType.tagno.isEmpty else { return 0 }
        
        let totalCompletionPercentage = equipmentType.tagno.reduce(0.0) { partialResult, tagno in
            partialResult + tagnoCompletionPercentage(for: tagno)
        }
        
        return totalCompletionPercentage / Double(equipmentType.tagno.count)
    }
    
    private func tagnoCompletionPercentage(for tagno: Tagno) -> Double {
        let totalParameters = tagno.parameter.count
        let completedParameters = tagno.parameter.filter { isParameterFilled($0) }.count
        guard totalParameters > 0 else { return 0 }
        return Double(completedParameters) / Double(totalParameters)
    }
    
    private var equipmentProgressBarColor: Color {
        switch completionPercentage {
        case 1.0:
            return .green
        case 0.5...:
            return .orange
        default:
            return .red
        }
    }
    
    private func isParameterFilled(_ parameter: Parameter) -> Bool {
        let inputValue = UserDefaults.standard.string(forKey: "parameter_\(parameter.parameterID)") ?? ""
        return !inputValue.isEmpty
    }
}

// MARK: - Equipment Type Supporting Views
struct EquipmentProgressView: View {
    let completionPercentage: Double
    let progressColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Equipment Completion: \(Int(completionPercentage * 100))%")
                .font(.headline)
                .padding(.horizontal)
            
            ProgressView(value: completionPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .frame(height: 10)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct TagnoListView: View {
    let equipmentType: EquipmentType
    @Binding var expandedSections: Set<Int>
    var onCompletionChanged: () -> Void
    
    var body: some View {
        List {
            ForEach(equipmentType.tagno, id: \.tagnoID) { tag in
                Section(header: TagnoSectionHeader(
                    tagno: tag,
                    onCompletionChanged: onCompletionChanged, expandedSections: $expandedSections
                )) {
                    if expandedSections.contains(tag.tagnoID) {
                        ForEach(tag.parameter, id: \.parameterID) { param in
                            ParameterRow(parameter: param, onParameterChange: onCompletionChanged)
                                .padding(.top, 20)
                        }
                    }
                }
            }
        }
        .padding(.bottom, 60)
    }
}

struct ExpandCollapseMenu: View {
    let equipmentType: EquipmentType
    @Environment(\.colorScheme) var colorScheme
    @Binding var expandedSections: Set<Int>
    
    var body: some View {
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

struct TagnoSectionHeader: View {
    let tagno: Tagno
    var onCompletionChanged: (() -> Void)?
    @Binding var expandedSections: Set<Int>
    @Environment(\.colorScheme) var colorScheme
    
    private var completionPercentage: Double {
        let totalParameters = tagno.parameter.count
        let completedParameters = tagno.parameter.filter { isParameterFilled($0) }.count
        guard totalParameters > 0 else { return 0 }
        return Double(completedParameters) / Double(totalParameters)
    }
    
    private var progressColor: Color {
        switch completionPercentage {
        case 1.0: return .green
        case 0.5...: return .orange
        default: return .red
        }
    }
    
    private var groupBoxBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : .white
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                GroupBox(label: Text("Tagnos: \(tagno.tagnoName)")
                    .foregroundColor(.primary)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                ) {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Completion: \(Int(completionPercentage * 100))%")
                                .font(.subheadline)
                                .padding(.top, 15)
                            Spacer()
                            Button(action: { toggleSection() }) {
                                Image(systemName: expandedSections.contains(tagno.tagnoID) ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        ProgressView(value: completionPercentage)
                            .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                            .frame(height: 6)
                            .padding(.top, 4)
                        
                        if expandedSections.contains(tagno.tagnoID) {
                            EquipmentStatusView()
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 4)
                }
                .onTapGesture {
                    toggleSection()
                }
            }
        } //End ScrollView
        .groupBoxStyle(CardGroupBox())
        .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: -30, trailing: 0))
    }
    
    struct CardGroupBox: GroupBoxStyle {
        @Environment(\.colorScheme) var colorScheme
        func makeBody(configuration: Configuration) -> some View {
            configuration.content
                .frame(maxWidth: .infinity)
                .padding()
                .cornerRadius(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                )
                .overlay(
                    configuration.label
                        .padding(.top, 15)
                        .padding(.leading, 15) // Padding di kiri
                        .padding(.trailing, 15), // Padding di kanan
                    alignment: .topLeading
                )
        }
    }
    
    private func toggleSection() {
        if expandedSections.contains(tagno.tagnoID) {
            expandedSections.remove(tagno.tagnoID)
        } else {
            expandedSections.insert(tagno.tagnoID)
        }
        onCompletionChanged?()
    }
    
    private func isParameterFilled(_ parameter: Parameter) -> Bool {
        let inputValue = UserDefaults.standard.string(forKey: "parameter_\(parameter.parameterID)") ?? ""
        return !inputValue.isEmpty
    }
}

struct EquipmentStatusView: View {
    @State private var equipmentStatus = "On"
    @State private var showCamera = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Equipment Status")
                .font(.headline)
                .foregroundColor(.gray)
                .textCase(nil)

            HStack(spacing: 20) {
                RadioButton(
                    id: "On",
                    label: "On",
                    isSelected: equipmentStatus == "On",
                    action: {
                        equipmentStatus = "On"
                    }
                )

                RadioButton(
                    id: "Off",
                    label: "Off",
                    isSelected: equipmentStatus == "Off",
                    action: {
                        equipmentStatus = "Off"
                        showCamera = true
                    }
                )
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            colorScheme == .dark ? Color(.systemBackground) : Color(.systemBackground)
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2))
        )
        .sheet(isPresented: $showCamera) {
            CameraView(isPresented: $showCamera)
        }
    }
}

struct RadioButton: View {
    let id: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(label)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct CameraView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Text("Camera View")
                .navigationTitle("Take Photo")
                .navigationBarItems(trailing: Button("Close") {
                    isPresented = false
                })
        }
    }
}

// MARK: - Parameter Row
struct ParameterRow: View {
    let parameter: Parameter
    var onParameterChange: (() -> Void)?
    @State private var inputValue: String = ""
    
    private var storageKey: String {
        "parameter_\(parameter.parameterID)"
    }
    
    private func isMandatory(_ mandatory: Mandatory) -> Bool {
        switch mandatory {
        case .int(let value): return value != 0
        case .bool(let value): return value
        }
    }
    
    private var isValid: Bool {
        switch parameter.formType {
        case "Min":
            guard let value = Double(inputValue),
                  let minValue = Double(String(parameter.min ?? 0)) else { return false }
            return value >= minValue
            
        case "Max":
            guard let value = Double(inputValue),
                  let maxValue = Double(String(parameter.max ?? 0)) else { return false }
            return value <= maxValue
            
        case "Range":
            guard let value = Double(inputValue),
                  let minValue = Double(String(parameter.min ?? 0)),
                  let maxValue = Double(String(parameter.max ?? 0)) else { return false }
            return value >= minValue && value <= maxValue
            
        case "Option":
            return inputValue == parameter.correctOption
            
        default:
            return true
        }
    }
    
    private var backgroundColor: Color {
        if inputValue.isEmpty { return Color(.systemBackground) }
        return isValid ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
    }
    
    private var options: [String] {
        parameter.booleanOption.split(separator: ",").map(String.init)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ParameterHeaderView(
                parameterName: parameter.parameterName,
                isMandatory: isMandatory(parameter.mandatory)
            )
            
            if parameter.formType == "Option" {
                ParameterOptionPicker(
                    options: options,
                    inputValue: $inputValue,
                    storageKey: storageKey
                )
            } else {
                ParameterInputField(
                    inputValue: $inputValue,
                    storageKey: storageKey,
                    unit: parameter.unit
                )
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2))
        )
        .padding(.horizontal)
        .onAppear {
            inputValue = UserDefaults.standard.string(forKey: storageKey) ?? ""
        }
        .onChange(of: inputValue) {
            onParameterChange?()
        }
    }
}

struct ParameterHeaderView: View {
    let parameterName: String
    let isMandatory: Bool
    
    var body: some View {
        HStack {
            Text(parameterName)
                .font(.headline)
            if isMandatory {
                Text("*")
                    .foregroundColor(.red)
                    .font(.headline)
            }
        }
    }
}

struct ParameterOptionPicker: View {
    let options: [String]
    @Binding var inputValue: String
    let storageKey: String
    
    var body: some View {
        Picker("Select", selection: Binding(
            get: { inputValue },
            set: { newValue in
                inputValue = newValue
                UserDefaults.standard.set(newValue, forKey: storageKey)
            }
        )) {
            Text("Select option").tag("")
            ForEach(options, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct ParameterInputField: View {
    @Binding var inputValue: String
    let storageKey: String
    let unit: String
    
    var body: some View {
        HStack {
            TextField("Enter value", text: Binding(
                get: { inputValue },
                set: { newValue in
                    inputValue = newValue
                    UserDefaults.standard.set(newValue, forKey: storageKey)
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            
            if !unit.isEmpty {
                Text(unit)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ActivityView(viewModel: AuthViewModel(), user: nil)
        .environmentObject(AuthViewModel())
}
