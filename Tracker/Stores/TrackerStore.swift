import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    func saveTracker(_ tracker: Tracker, categoryTitle: String) {
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.color = tracker.color
        trackerEntity.emoji = tracker.emoji
        
        let encoder = JSONEncoder()
        if let scheduleData = try? encoder.encode(tracker.schedule) {
            trackerEntity.schedule = scheduleData
        }
        
        let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        if let category = try? context.fetch(categoryFetchRequest).first {
            trackerEntity.category = category
        } else {
            let categoryEntity = TrackerCategoryCoreData(context: context)
            categoryEntity.title = categoryTitle
            trackerEntity.category = categoryEntity
        }
        
        do {
            try context.save()
            print("Трекер сохранен в Core Data: \(tracker.name)")
        } catch {
            print("Ошибка сохранения трекера: \(error)")
        }
    }
    
    func loadTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            var trackers: [Tracker] = []
            
            for trackerEntity in results {
                guard let id = trackerEntity.id,
                      let name = trackerEntity.name,
                      let color = trackerEntity.color,
                      let emoji = trackerEntity.emoji else {
                    continue
                }
                
                var schedule: [Weekday] = []
                if let scheduleData = trackerEntity.schedule {
                    let decoder = JSONDecoder()
                    schedule = (try? decoder.decode([Weekday].self, from: scheduleData)) ?? []
                }
                
                let categoryTitle = trackerEntity.category?.title ?? "Без категории"
                
                let tracker = Tracker(
                    id: id,
                    name: name,
                    color: color,
                    emoji: emoji,
                    schedule: schedule,
                    categoryTitle: categoryTitle
                )
                
                trackers.append(tracker)
            }
            
            print("Загружено трекеров из Core Data: \(trackers.count)")
            return trackers
        } catch {
            print("Ошибка загрузки трекеров: \(error)")
            return []
        }
    }
}
