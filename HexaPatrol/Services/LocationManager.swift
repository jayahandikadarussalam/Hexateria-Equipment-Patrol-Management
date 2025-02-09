//
//  LocationManager.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/01/25.

import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var locationName: String = "Getting location..."
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update location every 10 meters
        
        // Request authorization immediately
        locationManager.requestWhenInUseAuthorization()
        
        // Start updating immediately if we have permission
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                // Request immediate one-time update
                locationManager.requestLocation()
            default:
                break
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            self?.authorizationStatus = manager.authorizationStatus
            
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                // Start updates as soon as we get permission
                self?.locationManager.startUpdatingLocation()
                self?.locationManager.requestLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.location = location
        }
        
        // Reverse geocoding to get readable address
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    let area = placemark.name ?? ""
                    let locality = placemark.locality ?? ""
                    self.locationName = "\(area), \(locality)"
                } else {
                    // Fallback to coordinates
                    self.locationName = String(format: "%.4f, %.4f",
                        location.coordinate.latitude,
                        location.coordinate.longitude)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            print("Location error: \(error.localizedDescription)")
            self?.locationName = "Error getting location"
        }
    }
}

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var locationName: String = "Getting location..."
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        fetchLocationDetails(from: location)
        // **Stop location updates after first valid location**
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationName = "Location unavailable"
        print("Error getting location: \(error.localizedDescription)")
    }

    private func fetchLocationDetails(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? "Unknown City"
                let street = placemark.thoroughfare ?? "Unknown Street"
                let country = placemark.country ?? "Unknown Country"
                self.locationName = "\(street), \(city), \(country)"
            } else {
                self.locationName = "Location unavailable"
            }
        }
    }
}
