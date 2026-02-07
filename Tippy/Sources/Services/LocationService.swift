import CoreLocation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    var city: String?
    var state: String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }

    func requestLocationIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let placemark = placemarks?.first else { return }
            self?.city = placemark.locality
            self?.state = placemark.administrativeArea
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location is optional — silently ignore failures
    }
}
