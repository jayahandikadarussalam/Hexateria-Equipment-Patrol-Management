//
//  PlantViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/01/25.
//


import Foundation
import CoreData

class PlantViewModel: ObservableObject {
    private let context = PersistenceController.shared.context

    func savePlantsToCoreData(plants: [PlantData]) {
        do {
            for plant in plants {
                let plantEntity = Plant(context: context)
                plantEntity.plantID = Int64(plant.plantID)
                plantEntity.plantName = plant.plantName

                for area in plant.areaData {
                    let areaEntity = Area(context: context)
                    areaEntity.areaID = Int64(area.areaID)
                    areaEntity.areaName = area.areaName

                    for group in area.equipmentGroup {
                        let groupEntity = EquipmentGroup(context: context)
                        groupEntity.equipmentGroupID = Int64(group.equipmentGroupID)
                        groupEntity.equipmentGroupName = group.equipmentGroupName

                        for type in group.equipmentType {
                            let typeEntity = EquipmentType(context: context)
                            typeEntity.equipmentTypeID = Int64(type.equipmentTypeID)
                            typeEntity.equipmentTypeName = type.equipmentTypeName

                            for tag in type.tagno {
                                let tagEntity = Tagno(context: context)
                                tagEntity.tagnoID = Int64(tag.tagnoID)
                                tagEntity.tagnoName = tag.tagnoName
                                typeEntity.addToTagnos(tagEntity)
                            }

                            groupEntity.addToEquipmentTypes(typeEntity)
                        }

                        areaEntity.addToEquipmentGroups(groupEntity)
                    }

                    plantEntity.addToAreaData(areaEntity)
                }
            }

            try context.save()
            print("Plants saved to Core Data successfully.")
        } catch {
            print("Failed to save plants to Core Data: \(error)")
        }
    }
}