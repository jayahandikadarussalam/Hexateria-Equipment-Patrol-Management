//
//  EquipmentGroupModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/01/25.
//
//

import Foundation
import CoreData


extension EquipmentGroupModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EquipmentGroupModel> {
        return NSFetchRequest<EquipmentGroupModel>(entityName: "EquipmentGroupModel")
    }

    @NSManaged public var equipmentGroupID: Int64
    @NSManaged public var equipmentGroupName: String?
    @NSManaged public var areaFromGroup: EquipmentGroupModel?
    @NSManaged public var groupToType: NSSet?

}

// MARK: Generated accessors for groupToType
extension EquipmentGroupModel {

    @objc(addGroupToTypeObject:)
    @NSManaged public func addToGroupToType(_ value: EquipmentTypeModel)

    @objc(removeGroupToTypeObject:)
    @NSManaged public func removeFromGroupToType(_ value: EquipmentTypeModel)

    @objc(addGroupToType:)
    @NSManaged public func addToGroupToType(_ values: NSSet)

    @objc(removeGroupToType:)
    @NSManaged public func removeFromGroupToType(_ values: NSSet)

}

extension EquipmentGroupModel : Identifiable {

}
