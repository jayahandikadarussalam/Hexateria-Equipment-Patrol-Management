//
//  MockAuthViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 03/01/25.
//


class MockAuthViewModel: AuthViewModel {
    override init() {
        super.init()
        
        // Populate plants with mock data
        self.plants = [
            PlantData(
                plantID: 11,
                plantName: "PV1",
                areaData: [
                    AreaData(
                        areaID: 20,
                        areaName: "3100",
                        equipmentGroup: [
                            EquipmentGroup(
                                equipmentGroupID: 14,
                                equipmentGroupName: "PU",
                                equipmentType: [
                                    EquipmentType(
                                        equipmentTypeID: 9,
                                        equipmentTypeName: "PURC",
                                        tagno: [
                                            Tagno(
                                                tagnoID: 4,
                                                tagnoName: "PU-3102",
                                                parameter: [
                                                    Parameter(parameterID: 2, parameterName: "Oil Level", unit: "%", formType: "Range", booleanOption: "", correctOption: "", gap: "20", mandatory: .bool(false), min: 50, max: 90, ordering: 1),
                                                    Parameter(parameterID: 3, parameterName: "Oil Level Chamber", unit: "%", formType: "Range", booleanOption: "", correctOption: "", gap: "20", mandatory: .bool(false), min: 50, max: 90, ordering: 2),
                                                    Parameter(parameterID: 4, parameterName: "Base Condition", unit: "-", formType: "Option", booleanOption: "Good,Not Good", correctOption: "Good", gap: "0", mandatory: .bool(true), min: nil, max: nil, ordering: 3),
                                                    // Add other parameters as necessary
                                                ]
                                            )
                                        ]
                                    )
                                ]
                            )
                        ]
                    )
                ]
            )
        ]
    }
}