//
//  HistoryDetailModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/03/25.
//
//

import Foundation
import CoreData


extension HistoryDetailModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryDetailModel> {
        return NSFetchRequest<HistoryDetailModel>(entityName: "HistoryDetailModel")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var username: String?
    @NSManaged public var department: String?
    @NSManaged public var role: String?
    @NSManaged public var date: String?
    @NSManaged public var status: String?
    @NSManaged public var reasons: HistoryReasonModel?

}

extension HistoryDetailModel : Identifiable {

}
