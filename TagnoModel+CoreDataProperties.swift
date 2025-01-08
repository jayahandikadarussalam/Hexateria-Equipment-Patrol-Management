//
//  TagnoModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/01/25.
//
//

import Foundation
import CoreData


extension TagnoModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagnoModel> {
        return NSFetchRequest<TagnoModel>(entityName: "TagnoModel")
    }

    @NSManaged public var tagnoID: Int64
    @NSManaged public var tagnoModel: String?
    @NSManaged public var tagnoFromType: EquipmentTypeModel?
    @NSManaged public var tagnoToParam: NSSet?

}

// MARK: Generated accessors for tagnoToParam
extension TagnoModel {

    @objc(addTagnoToParamObject:)
    @NSManaged public func addToTagnoToParam(_ value: ParameterModel)

    @objc(removeTagnoToParamObject:)
    @NSManaged public func removeFromTagnoToParam(_ value: ParameterModel)

    @objc(addTagnoToParam:)
    @NSManaged public func addToTagnoToParam(_ values: NSSet)

    @objc(removeTagnoToParam:)
    @NSManaged public func removeFromTagnoToParam(_ values: NSSet)

}

extension TagnoModel : Identifiable {

}
