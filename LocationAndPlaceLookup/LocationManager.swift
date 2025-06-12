//
//  LocationManager.swift
//  LocationAndPlaceLookup
//
//  Created by John Kearon on 5/11/25.
//

import Foundation
import MapKit  // MapKit includes core location
import SwiftUI

@Observable

class LocationManager: NSObject, CLLocationManagerDelegate {
    // *** CRITICALLY IMPORTANT *** Always add info.plist message for Privacy - Location When in Use Usage Description
    // CLLocationManagerDelegate: The methods you use to receive events from an associated location-manager object.
    
    var location: CLLocation?  // holds the determined location
    private let locationManager = CLLocationManager() // only used in this class
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?
    
    // callback function - a function that is passed as an argument to another function and executed later, after the original function finishes its operation, essentially notifying the calling code when the asynchronous task is complete and providing any necessary results.
    var locationUpdated: ((CLLocation) -> Void)? // This is a function that can be called, passing in a location
    
    override init() {  // override init takes preceence over any other function which exists we're going
        super.init() // first call the init function that is defined in any super-class (parent)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()  // prompts the user for authorization
        locationManager.startUpdatingLocation()  
    }
    
    // Get a region around current location with specified radius in meters
    func getRegionAroundCurrentLocation(radiusInMeters: CLLocationDistance = 10000) -> MKCoordinateRegion? {  // 10000 is default value
        guard let location = location else {
//            fatalError("LocationManager: No location data available")
            return nil
        }
        
        return MKCoordinateRegion(  // Use "Ctrl M" to get the parameteters on separate lines
            center: location.coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
        
//        let coordinateRegion = MKCoordinateRegion(
//            center: location.coordinate,
//            latitudinalMeters: radius,
//            longitudinalMeters: radius
//        )
    }
    
}

// CLLocationManagerDelegate: The methods you use to receive events from an associated location-manager object.
// Delegate methods that Apple has created & will call, but that we filled out
extension LocationManager {
    
    // Tells the delegate that new location data is available.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation
        // Call the callback function to indicate we've updated a location
        locationUpdated?(newLocation)
        
        // You can uncomment this when you only want to get the location once, not repeatedly
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("LocationManager authorization granted")
        case .denied, .restricted:
            print("😡📍LocationManager authorization Denied")
            errorMessage = "😡📍Location access denied"
            manager.stopUpdatingLocation()
        case .notDetermined:
            print("LocationManager: authorization not determined yet")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            print("LOOK FOR NEW eNum for CLLocationManager.authorizationStatus!")
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        errorMessage = error.localizedDescription
        print("😡🗺️ ERROR LocationManager: \(errorMessage ?? "n/a")")
    }
}
