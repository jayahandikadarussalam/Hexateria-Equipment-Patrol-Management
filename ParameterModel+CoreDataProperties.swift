//
//  ParameterModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/01/25.
//
//

import Foundation
import CoreData


extension ParameterModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ParameterModel> {
        return NSFetchRequest<ParameterModel>(entityName: "ParameterModel")
    }

    @NSManaged public var parameterID: Int64
    @NSManaged public var parameterName: String?
    @NSManaged public var unit: String?
    @NSManaged public var formType: String?
    @NSManaged public var booleanOption: String?
    @NSManaged public var correctOption: String?
    @NSManaged public var gap: Int64
    @NSManaged public var mandatory: Bool
    @NSManaged public var min: Int64
    @NSManaged public var max: Int64
    @NSManaged public var ordering: Int64
    @NSManaged public var paramFromTagno: TagnoModel?

}

extension ParameterModel : Identifiable {

}
