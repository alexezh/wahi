import Foundation
import CoreData
import Photos

// Core Data will auto-generate PhotoPreference class

// Helper class for managing photo preferences
class PhotoPreferenceManager {
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func setPreference(for asset: PHAsset, preference: PhotoPreferenceType) {
        if preference == .like {
            // Use Photos framework to set favorite
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.init(for: asset).isFavorite = true
            }) { success, error in
                if let error = error {
                    print("Failed to set photo as favorite: \(error)")
                }
            }
        } else if preference == .dislike {
            // Remove from favorites if it was favorited
            if asset.isFavorite {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.init(for: asset).isFavorite = false
                }) { success, error in
                    if let error = error {
                        print("Failed to remove photo from favorites: \(error)")
                    }
                }
            }
            
            // Store dislike in Core Data
            let fetchRequest: NSFetchRequest<PhotoPreference> = PhotoPreference.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "photoId == %@", asset.localIdentifier)
            
            do {
                let existing = try viewContext.fetch(fetchRequest)
                let photoPreference: PhotoPreference
                
                if let existingPreference = existing.first {
                    photoPreference = existingPreference
                } else {
                    photoPreference = PhotoPreference(context: viewContext)
                    photoPreference.photoId = asset.localIdentifier
                }
                
                photoPreference.preference = preference.rawValue
                photoPreference.dateModified = Date()
                
                try viewContext.save()
            } catch {
                print("Failed to save photo preference: \(error)")
            }
        } else if preference == .neutral {
            // Remove from favorites if it was favorited
            if asset.isFavorite {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.init(for: asset).isFavorite = false
                }) { success, error in
                    if let error = error {
                        print("Failed to remove photo from favorites: \(error)")
                    }
                }
            }
            
            // Remove dislike from Core Data if it exists
            let fetchRequest: NSFetchRequest<PhotoPreference> = PhotoPreference.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "photoId == %@", asset.localIdentifier)
            
            do {
                let existing = try viewContext.fetch(fetchRequest)
                if let existingPreference = existing.first {
                    viewContext.delete(existingPreference)
                    try viewContext.save()
                }
            } catch {
                print("Failed to remove photo preference: \(error)")
            }
        }
    }
    
    func getPreference(for asset: PHAsset) -> PhotoPreferenceType {
        // Check if it's favorited in Photos app first
        if asset.isFavorite {
            return .like
        }
        
        // Check if it's disliked in our Core Data storage
        let fetchRequest: NSFetchRequest<PhotoPreference> = PhotoPreference.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "photoId == %@", asset.localIdentifier)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let preference = results.first, let preferenceValue = preference.preference {
                let prefType = PhotoPreferenceType(rawValue: preferenceValue) ?? .neutral
                // Only return dislike from Core Data, favorites come from Photos app
                if prefType == .dislike {
                    return .dislike
                }
            }
        } catch {
            print("Failed to fetch photo preference: \(error)")
        }
        
        return .neutral
    }
    
    func getFilteredAssets(from assets: [PHAsset], filter: PhotoFilterType) -> [PHAsset] {
        switch filter {
        case .all:
            return assets
        case .favorites:
            return assets.filter { $0.isFavorite }
        case .dislikes:
            return assets.filter { getPreference(for: $0) == .dislike }
        case .neutral:
            return assets.filter { !$0.isFavorite && getPreference(for: $0) != .dislike }
        case .notDisliked:
            return assets.filter { getPreference(for: $0) != .dislike }
        }
    }
}

enum PhotoPreferenceType: String, CaseIterable {
    case like = "like"
    case dislike = "dislike"
    case neutral = "neutral"
}

enum PhotoFilterType: String, CaseIterable {
    case all = "all"
    case favorites = "favorites"
    case dislikes = "dislikes"
    case neutral = "neutral"
    case notDisliked = "notDisliked"
    
    var displayName: String {
        switch self {
        case .all:
            return "All Photos"
        case .favorites:
            return "Favorites"
        case .dislikes:
            return "Disliked"
        case .neutral:
            return "Neutral"
        case .notDisliked:
            return "Photos"
        }
    }
    
    var iconName: String {
        switch self {
        case .all:
            return "photo.stack"
        case .favorites:
            return "heart.fill"
        case .dislikes:
            return "xmark.circle.fill"
        case .neutral:
            return "minus.circle"
        case .notDisliked:
            return "photo"
        }
    }
}