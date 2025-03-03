//
//  ReasonPatrol+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 16/02/25.
//
//

import Foundation
import CoreData


extension ReasonPatrol {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReasonPatrol> {
        return NSFetchRequest<ReasonPatrol>(entityName: "ReasonPatrol")
    }

    @NSManaged public var name: String?
    @NSManaged public var username: String?
    @NSManaged public var department: String?
    @NSManaged public var role: String?
    @NSManaged public var date: Date?
    @NSManaged public var status: String?
    @NSManaged public var reason: String?
    @NSManaged public var location: String?
    @NSManaged public var longitude: NSDecimalNumber?
    @NSManaged public var latitude: NSDecimalNumber?
    @NSManaged public var imageData: Data?

}

extension ReasonPatrol : Identifiable {

}
