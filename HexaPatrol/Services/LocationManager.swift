// LocationManager.swift
import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var locationName: String = "Getting location..."
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        
        // Reverse geocoding to get readable address
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                let area = placemark.name ?? ""
                let locality = placemark.locality ?? ""
                DispatchQueue.main.async {
                    self.locationName = "\(area), \(locality)"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

// LocationViewModel.swift
class LocationViewModel: ObservableObject {
    @Published private var locationManager = LocationManager()
    
    var locationName: String {
        locationManager.locationName
    }
    
    var currentLocation: CLLocation? {
        locationManager.location
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
}