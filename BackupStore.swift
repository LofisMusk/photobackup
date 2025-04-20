import Foundation

final class BackupStore {
    private let key = "LastBackedUp"
    private let defaults = UserDefaults.standard
    
    var lastBackedUpDate: Date? {
        defaults.object(forKey: key) as? Date
    }
    
    func updateLastDate(_ date: Date?) {
        defaults.setValue(date, forKey: key)
    }
}
