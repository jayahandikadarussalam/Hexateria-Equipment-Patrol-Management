//
//  PhotoTrxModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 26/02/25.
//
//

import Foundation
import CoreData


extension PhotoTrxModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoTrxModel> {
        return NSFetchRequest<PhotoTrxModel>(entityName: "PhotoTrxModel")
    }

    @NSManaged public var imageName: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var size: String?
    @NSManaged public var user: UserTrxModel?

}

extension PhotoTrxModel : Identifiable {

}
