//
//  PlantModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/01/25.
//
//

import Foundation
import CoreData


extension PlantModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlantModel> {
        return NSFetchRequest<PlantModel>(entityName: "PlantModel")
    }

    @NSManaged public var plantID: Int64
    @NSManaged public var plantName: String?
    @NSManaged public var plantToArea: NSSet?

}

// MARK: Generated accessors for plantToArea
extension PlantModel {

    @objc(addPlantToAreaObject:)
    @NSManaged public func addToPlantToArea(_ value: AreaModel)

    @objc(removePlantToAreaObject:)
    @NSManaged public func removeFromPlantToArea(_ value: AreaModel)

    @objc(addPlantToArea:)
    @NSManaged public func addToPlantToArea(_ values: NSSet)

    @objc(removePlantToArea:)
    @NSManaged public func removeFromPlantToArea(_ values: NSSet)

}

extension PlantModel : Identifiable {

}
