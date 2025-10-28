//
//  LocationService.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<(CLLocationCoordinate2D?, String), Never>?
    
    private override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocationOnce() async -> (CLLocationCoordinate2D?, String) {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        
        guard manager.authorizationStatus == .authorizedWhenInUse ||
              manager.authorizationStatus == .authorizedAlways else {
            print("Location access denied or restricted.")
            return (nil, TimeZone.current.identifier)
        }
        
        guard continuation == nil else {
            print("Warning: A location request is already in progress.")
            return (nil, TimeZone.current.identifier)
        }
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            continuation?.resume( returning:( nil, TimeZone.current.identifier))
            continuation = nil
            return
        }
        
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            let timezoneID = placemarks?.first?.timeZone?.identifier ?? TimeZone.current.identifier
            self.continuation?.resume(returning: (location.coordinate, timezoneID))
            self.continuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error:", error.localizedDescription)
        continuation?.resume(returning:  (nil, TimeZone.current.identifier))
        continuation = nil
    }
}
