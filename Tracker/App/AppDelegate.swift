import UIKit
import CoreData
import YandexMobileMetrica

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static var shared: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }
    
    static var context: NSManagedObjectContext? {
        shared?.persistentContainer.viewContext
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = persistentContainer
        
        if let configuration = YMMYandexMetricaConfiguration(apiKey: "667dff1e-bc2f-4383-be20-40c3d3247b33") {
               configuration.logs = true 
               YMMYandexMetrica.activate(with: configuration)
           }
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


