//
//  PlaceLookupViewModel.swift
//  LocationAndPlaceLookup
//
//  Created by John Kearon on 5/12/25.
//

import Foundation
import MapKit

@MainActor
@Observable

class PlaceViewModel {
    var places: [Place] = []
    
    func search(text: String, region: MKCoordinateRegion) async throws {
        // create a search request
        let searchRequest = MKLocalSearch.Request()
        // Pass in search text to the request
        searchRequest.naturalLanguageQuery = text
        // Establish a search region
        searchRequest.region = region
        // Now create the search object that performs the search
        let search = MKLocalSearch(request: searchRequest)
        // Run the search
        let response = try await search.start()
        if response.mapItems.isEmpty {
            throw NSError(domain: "No places found", code: -1, userInfo: [NSLocalizedDescriptionKey: "⁉️ No location found"])
        }
        self.places = response.mapItems.map(Place.init)
        
    }
}

