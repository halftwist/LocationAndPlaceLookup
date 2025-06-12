//
//  Place.swift
//  LocationAndPlaceLookup
//
//  Created by John Kearon on 5/12/25.
//

import Foundation
import MapKit
import Contacts  // used for CNPostalAddress

struct Place: Identifiable {  // Identifiable requires an id
    let id = UUID().uuidString  // A universally unique value to identify types, interfaces, and other items.
    private var mapItem: MKMapItem   // private means this variable will only be visible in this struct
    
    init(mapItem: MKMapItem) {  // mapItem passed into this struct
        self.mapItem = mapItem
    }
    
    // initialize a place from just coordinates
    init(location: CLLocation) async {
        // CLGeocoder (geocoder) - an object that can convert between geographic coordinates and place data
        // Reverse Geocoding - gets user-friendly data from geographic coordinates
        let geocoder = CLGeocoder()
        
        do {
            guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {  // Reverse Geocoding returns CLPlacemark
//                fatalError("No placemark found for location")
                self.init(mapItem: MKMapItem())  // generic MKMapIteem()
                return
            }
            let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))  // convert to MKPlacemark from CLPlacemark, then use that to create a MKMapItem
            self.init(mapItem: mapItem)
         } catch {
             print("😡🌎GEOCODING ERROR: \(error.localizedDescription)")
             self.init(mapItem: MKMapItem())
        }
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var latitude: CLLocationDegrees {  // CLLocationDegrees is an alias for Double
        self.mapItem.placemark.coordinate.latitude
    }
    
    var longitude: Double {  // CLLocationDegrees is an alias for Double
        self.mapItem.placemark.coordinate.longitude
    }
    
    // CLPLacemark is more flexible than CNPostalAddress but is more complicated and harder to use
    var address: String {
        // Make sure you import Contacts to use the "CN" structures
        let postalAddress = mapItem.placemark.postalAddress ?? CNPostalAddress()
        // Get String that is a multiline formatted postal address
        var address = CNPostalAddressFormatter().string(from: postalAddress)  // returns multiline address
        // Remove line feeds from multiline String above
        address = address.replacingOccurrences(of: "\n", with: ", ")

        return address
    }
}

