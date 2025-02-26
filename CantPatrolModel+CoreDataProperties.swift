//
//  CantPatrolModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 26/02/25.
//
//

import Foundation
import CoreData


extension CantPatrolModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CantPatrolModel> {
        return NSFetchRequest<CantPatrolModel>(entityName: "CantPatrolModel")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var username: String?
    @NSManaged public var department: String?
    @NSManaged public var role: String?
    @NSManaged public var userDate: String?
    @NSManaged public var status: String?
    @NSManaged public var reason: String?
    @NSManaged public var location: String?
    @NSManaged public var lon: NSDecimalNumber?
    @NSManaged public var lat: NSDecimalNumber?
    @NSManaged public var reasonDate: String?
    @NSManaged public var image: Data?

}

extension CantPatrolModel : Identifiable {

}
