import Foundation
import CoreData

@objc(FavoriteTournament)
public class FavoriteTournament: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var dateAdded: Date?
}

extension FavoriteTournament: Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteTournament> {
        return NSFetchRequest<FavoriteTournament>(entityName: "FavoriteTournament")
    }
}
