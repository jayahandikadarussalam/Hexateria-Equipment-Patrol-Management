//
//  UserTrxModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 26/02/25.
//
//

import Foundation
import CoreData


extension UserTrxModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserTrxModel> {
        return NSFetchRequest<UserTrxModel>(entityName: "UserTrxModel")
    }

    @NSManaged public var name: String?
    @NSManaged public var username: String?
    @NSManaged public var department: String?
    @NSManaged public var role: String?
    @NSManaged public var reasonTransactions: ReasonTrxModel?
    @NSManaged public var photoTransactions: PhotoTrxModel?

}

extension UserTrxModel : Identifiable {

}
