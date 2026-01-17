import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func isTrackerCompleted(trackerID: UUID, date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking tracker completion: \(error)")
            return false
        }
    }
    
    func saveRecord(trackerID: UUID, date: Date) {
        let trackerFetch: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerFetch.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        
        guard let tracker = try? context.fetch(trackerFetch).first else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let existingFetch: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        existingFetch.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        if let existing = try? context.fetch(existingFetch), !existing.isEmpty { return }
        
        let record = TrackerRecordCoreData(context: context)
        record.tracker = tracker
        record.date = date
        
        do {
            try context.save()
        } catch {
            print("Error saving record: \(error)")
        }
    }
    
    func deleteRecord(trackerID: UUID, date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetch: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetch.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            let records = try context.fetch(fetch)
            for record in records { context.delete(record) }
            if !records.isEmpty { try context.save() }
        } catch {
            print("Error deleting record: \(error)")
        }
    }
    
    func loadRecords() -> [TrackerRecord] {
        let fetch: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let results = try context.fetch(fetch)
            return results.compactMap { entity in
                guard let trackerID = entity.tracker?.id,
                      let date = entity.date else { return nil }
                return TrackerRecord(trackerID: trackerID, date: date)
            }
        } catch { return [] }
    }
    
    func getCompletedCount(for trackerID: UUID) -> Int {
        let fetch: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetch.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)
        
        do { return try context.count(for: fetch) }
        catch { return 0 }
    }
    
    func deleteAllRecords(for trackerID: UUID) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)

        do {
            let records = try context.fetch(request)
            records.forEach { context.delete($0) }
            try context.save()
        } catch {
            print("Ошибка удаления записей трекера: \(error)")
        }
    }
}
