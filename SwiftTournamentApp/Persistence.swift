import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "TournamentDataModel") // Nome exato do arquivo criado acima
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Erro Core Data: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
