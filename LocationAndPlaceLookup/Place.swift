//
//  Place.swift
//  LocationAndPlaceLookup
//
//  Created by John Kearon on 5/12/25.
//

import Foundation
import MapKit
import Contacts

struct Place: Identifiable {
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    // initialize a place from just coordinates
    init(location: CLLocation) async {
        let geocoder = CLGeocoder()
        do {
            guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {  // returns CLPlacemark
//                fatalError("No placemark found for location")
                self.init(mapItem: MKMapItem())
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
    
    var longitude: Double {
        self.mapItem.placemark.coordinate.longitude
    }
    
    var address: String {
        // Make sure you import Contacts to use the "CN" structures
        let postalAddress = mapItem.placemark.postalAddress ?? CNPostalAddress()
        // Get String that is a multiline formatted postal address
        var address = CNPostalAddressFormatter().string(from: postalAddress)
        // Remove line feeds from multiline String above
        address = address.replacingOccurrences(of: "\n", with: ", ")

        return address
    }
}

