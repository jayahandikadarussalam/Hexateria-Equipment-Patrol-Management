//
//  HierarchyDataPersistence.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 09/01/25.
//

import Foundation
import CoreData


class HierarchyDataPersistence {
    static let shared = HierarchyDataPersistence()
    var plants: [PlantData] = []
    public let context = PersistenceController.shared.container.viewContext
    private init() {}

    // MARK: - Save hirarki to CoreData
    func saveHierarchyData() async throws {
        print("Beginning saveHierarchyData execution")
        let context = PersistenceController.shared.context

        try await context.perform {
            for plant in self.plants {
                // Check if the Plant already exists
                let plantFetchRequest: NSFetchRequest<PlantModel> = PlantModel.fetchRequest()
                plantFetchRequest.predicate = NSPredicate(format: "plantID == %d", plant.plantID)
                let existingPlants = try? self.context.fetch(plantFetchRequest)
                let plantEntity: PlantModel

                if let existingPlant = existingPlants?.first {
                    plantEntity = existingPlant
                    // Update any fields if necessary
                    plantEntity.plantName = plant.plantName
                } else {
                    plantEntity = PlantModel(context: self.context)
                    plantEntity.plantID = Int64(plant.plantID)
                    plantEntity.plantName = plant.plantName
                }

                for area in plant.areaData {
                    // Check if the Area already exists
                    let areaFetchRequest: NSFetchRequest<AreaModel> = AreaModel.fetchRequest()
                    areaFetchRequest.predicate = NSPredicate(format: "areaID == %d AND areaFromPlant.plantID == %d", area.areaID, plant.plantID)
                    let existingAreas = try? self.context.fetch(areaFetchRequest)
                    let areaEntity: AreaModel

                    if let existingArea = existingAreas?.first {
                        areaEntity = existingArea
                        // Update any fields if necessary
                        areaEntity.areaName = area.areaName
                    } else {
                        areaEntity = AreaModel(context: self.context)
                        areaEntity.areaID = Int64(area.areaID)
                        areaEntity.areaName = area.areaName
                        // Set bidirectional relationship
                        areaEntity.areaFromPlant = plantEntity
                        plantEntity.addToPlantToArea(areaEntity)
                    }

                    for group in area.equipmentGroup {
                        // Check if the Equipment Group already exists
                        let groupFetchRequest: NSFetchRequest<EquipmentGroupModel> = EquipmentGroupModel.fetchRequest()
                        groupFetchRequest.predicate = NSPredicate(format: "equipmentGroupID == %d AND areaFromGroup.areaID == %d", group.equipmentGroupID, area.areaID)
                        let existingGroups = try? self.context.fetch(groupFetchRequest)
                        let groupEntity: EquipmentGroupModel

                        if let existingGroup = existingGroups?.first {
                            groupEntity = existingGroup
                            // Update any fields if necessary
                            groupEntity.equipmentGroupName = group.equipmentGroupName
                        } else {
                            groupEntity = EquipmentGroupModel(context: self.context)
                            groupEntity.equipmentGroupID = Int64(group.equipmentGroupID)
                            groupEntity.equipmentGroupName = group.equipmentGroupName
                            // Set bidirectional relationship
                            groupEntity.areaFromGroup = areaEntity
                            areaEntity.addToAreaToGroup(groupEntity)
                        }

                        for type in group.equipmentType {
                            // Check if the Equipment Type already exists
                            let typeFetchRequest: NSFetchRequest<EquipmentTypeModel> = EquipmentTypeModel.fetchRequest()
                            typeFetchRequest.predicate = NSPredicate(format: "equipmentTypeID == %d AND typeFromGroup.equipmentGroupID == %d", type.equipmentTypeID, group.equipmentGroupID)
                            let existingTypes = try? self.context.fetch(typeFetchRequest)
                            let typeEntity: EquipmentTypeModel

                            if let existingType = existingTypes?.first {
                                typeEntity = existingType
                                // Update any fields if necessary
                                typeEntity.equipmentTypeName = type.equipmentTypeName
                            } else {
                                typeEntity = EquipmentTypeModel(context: self.context)
                                typeEntity.equipmentTypeID = Int64(type.equipmentTypeID)
                                typeEntity.equipmentTypeName = type.equipmentTypeName
                                // Set bidirectional relationship
                                typeEntity.typeFromGroup = groupEntity
                                groupEntity.addToGroupToType(typeEntity)
                            }

                            for tagno in type.tagno {
                                // Check if the Tagno already exists
                                let tagnoFetchRequest: NSFetchRequest<TagnoModel> = TagnoModel.fetchRequest()
                                tagnoFetchRequest.predicate = NSPredicate(format: "tagnoID == %d AND tagnoFromType.equipmentTypeID == %d", tagno.tagnoID, type.equipmentTypeID)
                                let existingTagnos = try? self.context.fetch(tagnoFetchRequest)
                                let tagnoEntity: TagnoModel

                                if let existingTagno = existingTagnos?.first {
                                    tagnoEntity = existingTagno
                                    // Update any fields if necessary
                                    tagnoEntity.tagnoName = tagno.tagnoName
                                } else {
                                    tagnoEntity = TagnoModel(context: self.context)
                                    tagnoEntity.tagnoID = Int64(tagno.tagnoID)
                                    tagnoEntity.tagnoName = tagno.tagnoName
                                    // Set bidirectional relationship
                                    tagnoEntity.tagnoFromType = typeEntity
                                    typeEntity.addToTypeToTagno(tagnoEntity)
                                }

                                for param in tagno.parameter {
                                    // Check if the Parameter already exists
                                    let paramFetchRequest: NSFetchRequest<ParameterModel> = ParameterModel.fetchRequest()
                                    paramFetchRequest.predicate = NSPredicate(format: "parameterID == %d AND paramFromTagno.tagnoID == %d", param.parameterID, tagno.tagnoID)
                                    let existingParams = try? self.context.fetch(paramFetchRequest)
                                    let paramEntity: ParameterModel

                                    if let existingParam = existingParams?.first {
                                        paramEntity = existingParam
                                        // Update any fields if necessary
                                        paramEntity.parameterName = param.parameterName
                                        paramEntity.unit = param.unit
                                        paramEntity.formType = param.formType
                                        paramEntity.booleanOption = param.booleanOption
                                        paramEntity.correctOption = param.correctOption
                                        paramEntity.gap = param.gap
                                        paramEntity.min = Int64(param.min!)
                                        paramEntity.max = Int64(param.max!)
                                        paramEntity.ordering = Int64(param.ordering)
                                    } else {
                                        paramEntity = ParameterModel(context: self.context)
                                        paramEntity.parameterID = Int64(param.parameterID)
                                        paramEntity.parameterName = param.parameterName
                                        paramEntity.unit = param.unit
                                        paramEntity.formType = param.formType
                                        paramEntity.booleanOption = param.booleanOption
                                        paramEntity.correctOption = param.correctOption
                                        paramEntity.gap = param.gap
                                        paramEntity.min = Int64(param.min!)
                                        paramEntity.max = Int64(param.max!)
                                        paramEntity.ordering = Int64(param.ordering)
                                        // Set bidirectional relationship
                                        paramEntity.paramFromTagno = tagnoEntity
                                        tagnoEntity.addToTagnoToParam(paramEntity)
                                    }
                                }
                            }
                        }
                    }
                }
                print("Completed processing plant")
            }

            print("Attempting to save context")
            try self.context.save()
            print("Successfully saved context")
        }
    }
    
    // MARK: - Load hirarki from CoreData
    func loadHierarchyData() async throws -> [PlantData] {
        print("Beginning loadHierarchyData execution")
        let context = PersistenceController.shared.context
        var plants: [PlantData] = []
        
        try await context.perform {
            // Fetch all plants
            let plantRequest = PlantModel.fetchRequest()
            let plantEntities = try context.fetch(plantRequest)
            
            for plantEntity in plantEntities {
                var areas: [AreaData] = []
                
                // Load areas for each plant
                let areaEntities = plantEntity.plantToArea?.allObjects as? [AreaModel] ?? []
                for areaEntity in areaEntities {
                    var groups: [EquipmentGroup] = []
                    
                    // Load equipment groups for each area
                    let groupEntities = areaEntity.areaToGroup?.allObjects as? [EquipmentGroupModel] ?? []
                    for groupEntity in groupEntities {
                        var types: [EquipmentType] = []
                        
                        // Load equipment types for each group
                        let typeEntities = groupEntity.groupToType?.allObjects as? [EquipmentTypeModel] ?? []
                        for typeEntity in typeEntities {
                            var tagnos: [Tagno] = []
                            
                            // Load tagnos for each type
                            let tagnoEntities = typeEntity.typeToTagno?.allObjects as? [TagnoModel] ?? []
                            for tagnoEntity in tagnoEntities {
                                var parameters: [Parameter] = []
                                
                                // Load parameters for each tagno
                                let paramEntities = tagnoEntity.tagnoToParam?.allObjects as? [ParameterModel] ?? []
                                for paramEntity in paramEntities {
                                    let mandatory: Mandatory = paramEntity.mandatory ?
                                        .bool(true) : .int(0)
                                    
                                    let parameter = Parameter(
                                        parameterID: Int(paramEntity.parameterID),
                                        parameterName: paramEntity.parameterName ?? "",
                                        unit: paramEntity.unit ?? "",
                                        formType: paramEntity.formType ?? "",
                                        booleanOption: paramEntity.booleanOption ?? "",
                                        correctOption: paramEntity.correctOption ?? "",
                                        gap: paramEntity.gap ?? "",
                                        mandatory: mandatory,
                                        min: Int(paramEntity.min),
                                        max: Int(paramEntity.max),
                                        ordering: Int(paramEntity.ordering)
                                    )
                                    
                                    parameters.append(parameter)
                                }
                                
                                // Sort parameters by ordering
                                parameters.sort { $0.ordering < $1.ordering }
                                
                                let tagno = Tagno(
                                    tagnoID: Int(tagnoEntity.tagnoID),
                                    tagnoName: tagnoEntity.tagnoName ?? "",
                                    parameter: parameters
                                )
                                
                                tagnos.append(tagno)
                            }
                            
                            let type = EquipmentType(
                                equipmentTypeID: Int(typeEntity.equipmentTypeID),
                                equipmentTypeName: typeEntity.equipmentTypeName ?? "",
                                tagno: tagnos
                            )
                            
                            types.append(type)
                        }
                        
                        let group = EquipmentGroup(
                            equipmentGroupID: Int(groupEntity.equipmentGroupID),
                            equipmentGroupName: groupEntity.equipmentGroupName ?? "",
                            equipmentType: types
                        )
                        
                        groups.append(group)
                    }
                    
                    let area = AreaData(
                        areaID: Int(areaEntity.areaID),
                        areaName: areaEntity.areaName ?? "",
                        equipmentGroup: groups
                    )
                    
                    areas.append(area)
                }
                
                let plant = PlantData(
                    plantID: Int(plantEntity.plantID),
                    plantName: plantEntity.plantName ?? "",
                    areaData: areas
                )
                
                plants.append(plant)
            }
            print("Successfully loaded hierarchy data")
        }
        
        return plants
    }
}

