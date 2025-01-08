//
//  AreaModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/01/25.
//
//

import Foundation
import CoreData


extension AreaModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AreaModel> {
        return NSFetchRequest<AreaModel>(entityName: "AreaModel")
    }

    @NSManaged public var areaID: Int64
    @NSManaged public var areaName: String?
    @NSManaged public var areaFromPlant: PlantModel?
    @NSManaged public var areaToGroup: NSSet?

}

// MARK: Generated accessors for areaToGroup
extension AreaModel {

    @objc(addAreaToGroupObject:)
    @NSManaged public func addToAreaToGroup(_ value: EquipmentGroupModel)

    @objc(removeAreaToGroupObject:)
    @NSManaged public func removeFromAreaToGroup(_ value: EquipmentGroupModel)

    @objc(addAreaToGroup:)
    @NSManaged public func addToAreaToGroup(_ values: NSSet)

    @objc(removeAreaToGroup:)
    @NSManaged public func removeFromAreaToGroup(_ values: NSSet)

}

extension AreaModel : Identifiable {

}
