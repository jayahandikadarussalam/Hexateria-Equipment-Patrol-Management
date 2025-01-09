//
//  PlantViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/01/25.
//


import Foundation
import CoreData

class HirarkiViewModel: ObservableObject {
    private let context = PersistenceController.shared.context
    
//    func saveHirarkiData(
//        context: NSManagedObjectContext,
//        plantID: Int64,
//        plantName: String?,
//        areaData: [(areaID: Int64, areaName: String?, groupData: [(groupID: Int64, groupName: String?, typeData: [(typeID: Int64, typeName: String?, tagnoData: [(tagnoID: Int64, tagnoName: String?, paramData: [(paramID: Int64, paramName: String?, unit: String?, formType: String?, booleanOption: String?, correctOption: String?, gap: Int64, mandatory: Bool, min: Int64, max: Int64, ordering: Int64)])])])])]
//    ) {
//        do {
//            // Fetch or create PlantModel
//            let plantFetchRequest: NSFetchRequest<PlantModel> = PlantModel.fetchRequest()
//            plantFetchRequest.predicate = NSPredicate(format: "plantID == %d", plantID)
//            let plant: PlantModel
//            
//            if let existingPlant = try context.fetch(plantFetchRequest).first {
//                plant = existingPlant
//            } else {
//                plant = PlantModel(context: context)
//                plant.plantID = plantID
//            }
//            
//            // Update plant name
//            plant.plantName = plantName
//            
//            // Handle AreaModel relationships
//            for area in areaData {
//                let areaFetchRequest: NSFetchRequest<AreaModel> = AreaModel.fetchRequest()
//                areaFetchRequest.predicate = NSPredicate(format: "areaID == %d", area.areaID)
//                let areaModel: AreaModel
//                
//                if let existingArea = try context.fetch(areaFetchRequest).first {
//                    areaModel = existingArea
//                } else {
//                    areaModel = AreaModel(context: context)
//                    areaModel.areaID = area.areaID
//                }
//                
//                areaModel.areaName = area.areaName
//                areaModel.areaFromPlant = plant
//                
//                for group in area.groupData {
//                    let groupFetchRequest: NSFetchRequest<EquipmentGroupModel> = EquipmentGroupModel.fetchRequest()
//                    groupFetchRequest.predicate = NSPredicate(format: "equipmentGroupID == %d", group.groupID)
//                    let groupModel: EquipmentGroupModel
//                    
//                    if let existingGroup = try context.fetch(groupFetchRequest).first {
//                        groupModel = existingGroup
//                    } else {
//                        groupModel = EquipmentGroupModel(context: context)
//                        groupModel.equipmentGroupID = group.groupID
//                    }
//                    
//                    groupModel.equipmentGroupName = group.groupName
//                    groupModel.areaFromGroup = areaModel
//                    
//                    for type in group.typeData {
//                        let typeFetchRequest: NSFetchRequest<EquipmentTypeModel> = EquipmentTypeModel.fetchRequest()
//                        typeFetchRequest.predicate = NSPredicate(format: "equipmentTypeID == %d", type.typeID)
//                        let typeModel: EquipmentTypeModel
//                        
//                        if let existingType = try context.fetch(typeFetchRequest).first {
//                            typeModel = existingType
//                        } else {
//                            typeModel = EquipmentTypeModel(context: context)
//                            typeModel.equipmentTypeID = type.typeID
//                        }
//                        
//                        typeModel.equipmentTypeName = type.typeName
//                        typeModel.typeFromGroup = groupModel
//                        
//                        for tagno in type.tagnoData {
//                            let tagnoFetchRequest: NSFetchRequest<TagnoModel> = TagnoModel.fetchRequest()
//                            tagnoFetchRequest.predicate = NSPredicate(format: "tagnoID == %d", tagno.tagnoID)
//                            let tagnoModel: TagnoModel
//                            
//                            if let existingTagno = try context.fetch(tagnoFetchRequest).first {
//                                tagnoModel = existingTagno
//                            } else {
//                                tagnoModel = TagnoModel(context: context)
//                                tagnoModel.tagnoID = tagno.tagnoID
//                            }
//                            
//                            tagnoModel.tagnoModel = tagno.tagnoName
//                            tagnoModel.tagnoFromType = typeModel
//                            
//                            for param in tagno.paramData {
//                                let paramFetchRequest: NSFetchRequest<ParameterModel> = ParameterModel.fetchRequest()
//                                paramFetchRequest.predicate = NSPredicate(format: "parameterID == %d", param.paramID)
//                                let paramModel: ParameterModel
//                                
//                                if let existingParam = try context.fetch(paramFetchRequest).first {
//                                    paramModel = existingParam
//                                } else {
//                                    paramModel = ParameterModel(context: context)
//                                    paramModel.parameterID = param.paramID
//                                }
//                                
//                                paramModel.parameterName = param.paramName
//                                paramModel.unit = param.unit
//                                paramModel.formType = param.formType
//                                paramModel.booleanOption = param.booleanOption
//                                paramModel.correctOption = param.correctOption
//                                paramModel.gap = param.gap
//                                paramModel.mandatory = param.mandatory
//                                paramModel.min = param.min
//                                paramModel.max = param.max
//                                paramModel.ordering = param.ordering
//                                paramModel.paramFromTagno = tagnoModel
//                                
//                                tagnoModel.addToTagnoToParam(paramModel)
//                            }
//                            
//                            typeModel.addToTypeToTagno(tagnoModel)
//                        }
//                        
//                        groupModel.addToGroupToType(typeModel)
//                    }
//                    
//                    areaModel.addToAreaToGroup(groupModel)
//                }
//                
//                plant.addToPlantToArea(areaModel)
//            }
//            
//            if context.hasChanges {
//                try context.save()
//                print("Hierarchy data saved successfully.")
//            }
//        } catch {
//            print("Failed to save hierarchy data: \(error)")
//        }
//    }
//    
//    func loadHirarkiData(context: NSManagedObjectContext) {
//        // Fetch PlantModel data
//        let plantFetchRequest: NSFetchRequest<PlantModel> = PlantModel.fetchRequest()
//        do {
//            let plants = try context.fetch(plantFetchRequest)
//            
//            // Iterate through plants and load related data
//            for plant in plants {
//                // Load AreaModel for each Plant
//                if let areaSet = plant.plantToArea as? Set<AreaModel> {
//                    for area in areaSet {
//                        // Load EquipmentGroupModel for each Area
//                        if let equipmentGroupSet = area.areaToGroup as? Set<EquipmentGroupModel> {
//                            for group in equipmentGroupSet {
//                                // Load EquipmentTypeModel for each EquipmentGroup
//                                if let equipmentTypeSet = group.groupToType as? Set<EquipmentTypeModel> {
//                                    for equipmentType in equipmentTypeSet {
//                                        // Load TagnoModel for each EquipmentType
//                                        if let tagnoSet = equipmentType.typeToTagno as? Set<TagnoModel> {
//                                            for tagno in tagnoSet {
//                                                // Load ParameterModel for each Tagno
//                                                if let parameterSet = tagno.tagnoToParam as? Set<ParameterModel> {
//                                                    for parameter in parameterSet {
//                                                        // Handle parameter data here
//                                                        print("Parameter: \(parameter.parameterName ?? "No name")")
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        } catch {
//            print("Error fetching hirarki data: \(error)")
//        }
//    }

}
