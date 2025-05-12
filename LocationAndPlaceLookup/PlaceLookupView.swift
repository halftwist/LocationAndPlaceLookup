//
//  PlaceLookupView.swift
//  LocationAndPlaceLookup
//
//  Created by John Kearon on 5/12/25.
//

import SwiftUI
import MapKit

struct PlaceLookupView: View {
    let locationManager: LocationManager // passed in from the parent view
    @State var placeVM = PlaceViewModel()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var searchRegion = MKCoordinateRegion()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(placeVM.places, rowContent: { place in
                VStack(alignment: .leading) {
                    Text(place.name)
                        .font(.title2)
                    Text(place.address)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            })
            .listStyle(.plain)
            .navigationTitle("Location Searh")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {  // title & action
                        dismiss()
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .onDisappear {
            searchTask?.cancel()  // Cancel any outstanding Tasks when View dismisses
        }
        .onAppear {  // Only need to get searchRegion when View appears
            searchRegion = locationManager.getRegionAroundCurrentLocation() ?? MKCoordinateRegion()
        }
        .onChange(of: searchText) { oldValue, newValue in

            searchTask?.cancel()  // Stop any existing Tasks that haven't been completed
            // If search string is empty, clear out the list
            guard !searchText.isEmpty else {
                placeVM.places.removeAll()
                return
            }
            
            // Create a new search task
            searchTask = Task {
                do {
                    //debouncing - limiting how often a function gets called. Debouncing is especially useful in limiting excess and unnecessary API calls that might be expensive or invoke a rate limit or throttle
                    // Wait 300ms before running the current Task. Any typing before the Task has run cancels the old task. This prevents searches happening quickly if a user types fast, and will reduce chances that Apple ccuts off search because too many searches execute too quickly

                    try await Task.sleep(for: .milliseconds(300))
                    
                    if Task.isCancelled { return }
                    
                    if searchText == newValue {
                        try await placeVM.search(text: newValue, region: searchRegion)
                    }
                } catch {
                    if !Task.isCancelled {
                        print("😡 ERROR: \(error.localizedDescription)")
                    }
                }
            }
            
            
        }

    }
}

#Preview {
    PlaceLookupView(locationManager: LocationManager())
}
