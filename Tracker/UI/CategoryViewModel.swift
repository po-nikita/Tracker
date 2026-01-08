import Foundation
import CoreData

final class CategoryViewModel {
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategoryCoreData] = []
    private(set) var selectedCategory: TrackerCategoryCoreData?
    
    var onUpdate: (() -> Void)?
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        loadCategories()
    }
    
    func loadCategories() {
        categories = categoryStore.fetchCategories()
        onUpdate?()
    }
    
    func addCategory(title: String) {
        categoryStore.addCategory(title: title) {[ weak self] in
            self?.loadCategories()
        }
    }
    
    func category(at index: Int) -> TrackerCategoryCoreData {
        categories[index]
    }
    
    func selectCategory(_ category: TrackerCategoryCoreData) {
        selectedCategory = category
        onUpdate?()
    }
    
    func isSelected(_ category: TrackerCategoryCoreData) -> Bool {
        selectedCategory == category
    }
    
}
