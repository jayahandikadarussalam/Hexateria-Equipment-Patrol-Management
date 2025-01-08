//
//  EquipmentTypeModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/01/25.
//
//

import Foundation
import CoreData


extension EquipmentTypeModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EquipmentTypeModel> {
        return NSFetchRequest<EquipmentTypeModel>(entityName: "EquipmentTypeModel")
    }

    @NSManaged public var equipmentTypeID: Int64
    @NSManaged public var equipmentTypeName: String?
    @NSManaged public var typeFromGroup: EquipmentGroupModel?
    @NSManaged public var typeToTagno: NSSet?

}

// MARK: Generated accessors for typeToTagno
extension EquipmentTypeModel {

    @objc(addTypeToTagnoObject:)
    @NSManaged public func addToTypeToTagno(_ value: TagnoModel)

    @objc(removeTypeToTagnoObject:)
    @NSManaged public func removeFromTypeToTagno(_ value: TagnoModel)

    @objc(addTypeToTagno:)
    @NSManaged public func addToTypeToTagno(_ values: NSSet)

    @objc(removeTypeToTagno:)
    @NSManaged public func removeFromTypeToTagno(_ values: NSSet)

}

extension EquipmentTypeModel : Identifiable {

}
