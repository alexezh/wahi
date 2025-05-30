//
//  ContentView.swift
//  wahi
//
//  Created by alexezh on 5/26/25.
//

import CoreData
import MapKit
import PhotosUI
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showSheet = false

    @State private var isSheetExpanded: Bool = false

    @State private var showPhotoLibrary = false

    var body: some View {
        ZStack {
            MapView()

            // Show the system photo picker as a sheet when showPhotoLibrary is true
            if showPhotoLibrary {
                PhotoLibraryView(isPresented: $showPhotoLibrary)
                    .ignoresSafeArea()
                    .transition(.move(edge: .bottom))
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button(action: {
                    // Map button action: hide photo library, show map
                    withAnimation {
                        showPhotoLibrary = false
                    }
                }) {
                    VStack {
                        Image(systemName: "map")
                            .font(.system(size: 24))
                        Text("Map")
                            .font(.caption)
                    }
                }
                Spacer()
                Button(action: {
                    // Places button action: show full photo library
                    withAnimation {
                        showPhotoLibrary = true
                    }
                }) {
                    VStack {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 24))
                        Text("Places")
                            .font(.caption)
                    }
                }
                Spacer()
                Button(action: {
                    // Camera button action
                    // addItem()
                }) {
                    VStack {
                        Image(systemName: "camera")
                            .font(.system(size: 24))
                        Text("Camera")
                            .font(.caption)
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView().environment(
        \.managedObjectContext, PersistenceController.preview.container.viewContext)
}
