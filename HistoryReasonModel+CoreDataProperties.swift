//
//  HistoryReasonModel+CoreDataProperties.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/03/25.
//
//

import Foundation
import CoreData


extension HistoryReasonModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryReasonModel> {
        return NSFetchRequest<HistoryReasonModel>(entityName: "HistoryReasonModel")
    }

    @NSManaged public var id: Int64
    @NSManaged public var userId: String?
    @NSManaged public var status: String?
    @NSManaged public var date: String?
    @NSManaged public var reason: String?
    @NSManaged public var historyDetail: HistoryDetailModel?

}

extension HistoryReasonModel : Identifiable {

}
