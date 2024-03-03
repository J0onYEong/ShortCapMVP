//
//  SharedShortForm+CoreDataProperties.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/4/24.
//
//

import Foundation
import CoreData


extension SharedShortForm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SharedShortForm> {
        return NSFetchRequest<SharedShortForm>(entityName: "SharedShortForm")
    }

    @NSManaged public var url: String?
    @NSManaged public var sfData: SSFData?
    
    override func awakeFromInsert() {
        super.awakeFromInsert()

        setPrimitiveValue(UUID().uuidString, forKey: #keyPath(SharedShortForm.url))
    }
}

extension SharedShortForm : Identifiable {

}
