//
//  SharedListView.swift
//  reminora
//
//  Created by alexezh on 7/17/25.
//


import Foundation
import CoreData
import Photos
import SwiftUI

// MARK: - Shared List View
struct SharedListView: View {
    let context: NSManagedObjectContext
    let userId: String
    let onPhotoTap: (PHAsset) -> Void
    let onPinTap: (Place) -> Void
    let onPhotoStackTap: ([PHAsset]) -> Void
    let onLocationTap: ((NearbyLocation) -> Void)?
    
    @State private var items: [any RListViewItem] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if items.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "shared.with.you")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Shared Items")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Items shared with you will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    RListView(
                        dataSource: .mixed(items),
                        onPhotoTap: onPhotoTap,
                        onPinTap: onPinTap,
                        onPhotoStackTap: onPhotoStackTap,
                        onLocationTap: onLocationTap
                    )
                }
            }
            .navigationTitle("Shared")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await loadItems()
        }
    }
    
    private func loadItems() async {
        isLoading = true
        let loadedItems = await SharedListService.shared.getSharedItems(context: context, userId: userId)
        print("🔍 SharedListView loaded \(loadedItems.count) items")
        await MainActor.run {
            self.items = loadedItems
            self.isLoading = false
        }
    }
}
