import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do {
            return try context.fetch(request)
        } catch {
            print("Ошибка загрузки категорий: \(error)")
            return []
        }
    }
    
    func addCategory(title: String, completion: @escaping () -> Void) {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        do {
            try context.save()
            completion()
        } catch {
            print("Ошибка сохранения категории: \(error)")
        }
    }
}
