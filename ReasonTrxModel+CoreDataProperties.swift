//
//  ReasonTrxModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 26/02/25.
//
//

import Foundation
import CoreData


extension ReasonTrxModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReasonTrxModel> {
        return NSFetchRequest<ReasonTrxModel>(entityName: "ReasonTrxModel")
    }

    @NSManaged public var date: Date?
    @NSManaged public var latitude: NSDecimalNumber?
    @NSManaged public var location: String?
    @NSManaged public var longitude: NSDecimalNumber?
    @NSManaged public var name: String?
    @NSManaged public var reason: String?
    @NSManaged public var status: String?
    @NSManaged public var user: UserTrxModel?

}

extension ReasonTrxModel : Identifiable {

}
