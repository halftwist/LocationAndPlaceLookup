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
    @Binding var selectedPlace: Place?  // Passed in from the parent View
    @State var placeVM = PlaceViewModel()  // creates a object from this class
    @State private var searchText = ""
    
    // Task - a data type that consists of a closure containing program instructions that are treated as a unit of asynchronous work. Tasks can be stored in a variable. Tasks are run after creation, and can be delayed, or cancelled.
    @State private var searchTask: Task<Void, Never>?
    @State private var searchRegion = MKCoordinateRegion()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    //  ContentUnavailableView - An interface, consisting of a label and additional content, that you display when the content of your app is unavailable to users.
                    //  It is recommended to use ContentUnavailableView in situations where a view’s content cannot be displayed. That could be caused by a network error, a list without items, a search that returns no results etc.
                    ContentUnavailableView("No Results", systemImage: "mappin.slash")
                } else {
                    List(placeVM.places, rowContent: { place in
                        VStack(alignment: .leading) {
                            Text(place.name)
                                .font(.title2)
                            Text(place.address)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .onTapGesture {
                            selectedPlace = place  // the place selected from the list
                            dismiss()  // close this screen and return to the parent view (ContentView)
                        }
                    })
                }
            }           
            .listStyle(.plain)
            .navigationTitle("Location Searh")
            .navigationBarTitleDisplayMode(.inline)  // when user clicks in search field the navigationBarTitle will go away
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {  // title & action
                        dismiss()
                    }
                }
            }
        }
//        searchable(text:placement:prompt:)
//        Marks this view as searchable, which configures the display of a search field.
        .searchable(text: $searchText)
        .autocorrectionDisabled(true)
        .onDisappear {
            searchTask?.cancel()  // Cancel any outstanding Tasks when View dismisses
        }
        .onAppear {  // Only need to get searchRegion when View appears using the function defined in our LocationManager class
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
            searchTask = Task {  // Task contained within a closure
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
    // .constant used since selectedPlace is a binding variable
    PlaceLookupView(locationManager: LocationManager(), selectedPlace: .constant(Place(mapItem: MKMapItem())))
}
