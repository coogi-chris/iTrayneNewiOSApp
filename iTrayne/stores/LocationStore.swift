//
//  LocationStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 4/6/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

class LocationStore: NSObject, ObservableObject {
    
    @Published var centerCordinate:CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var userAddress:String = ""
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }
    
    func getUserCurrentCLLocation(completion:((CLLocation)->Void)? = nil) {
        guard let location = self.lastLocation else { return }
        self.getLocationPlacemark(location: location, success: { placemark in
            if let completion = completion {
                completion(location)
            }
        })
    }
    
    func getCurrentUserLocationAddress(completion:((String)->Void)? = nil) {
        guard let location = self.lastLocation else { return }
        self.getLocationPlacemark(location: location, success: { placemark in
            let address = self.getUserAddress(placemark: placemark)
            self.userAddress = address
            if let completion = completion {
                completion(address)
            }
        })
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }

    }

    private let locationManager = CLLocationManager()
}

extension LocationStore: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        //print(#function, statusString)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.centerCordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.latitude)
        self.lastLocation = location
        //print(#function, location)
    }
    private func getUserAddress(placemark:CLPlacemark) -> String {
        var address:String = ""
        
        let name = placemark.name ?? "unknown"
        let city = placemark.locality ?? "unknown"
        let state = placemark.administrativeArea ?? "unknown"
        let zipCode = placemark.postalCode ?? "unknown"
        
        address += name
        address += ", "
        address += city
        address += ", "
        address += state
        address += " "
        address += zipCode
        
        return address
    }
    
    private func getLocationPlacemark(location:CLLocation, success:((CLPlacemark)->Void)? = nil, error:((Error)->Void)? = nil) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, err) in
            if let placemarks = placemarks, let placemark = placemarks.first {
                if let success = success{ success(placemark) }
            }
            if let err = err {
                if let error = error{ error(err) }
            }
        }
    }

}

struct randomLocations {

    // create random locations (lat and long coordinates) around user's location
    func getMockLocationsFor(location: CLLocation, itemCount: Int) -> [CLLocation] {
        
        func getBase(number: Double) -> Double {
            return round(number * 1000)/1000
        }
        func randomCoordinate() -> Double {
            return Double(arc4random_uniform(140)) * 0.0001
        }
        
        let baseLatitude = getBase(number: location.coordinate.latitude - 0.007)
        // longitude is a little higher since I am not on equator, you can adjust or make dynamic
        let baseLongitude = getBase(number: location.coordinate.longitude - 0.008)
        
        var items = [CLLocation]()
        for _ in 0..<itemCount {
            
            let randomLat = baseLatitude + randomCoordinate()
            let randomLong = baseLongitude + randomCoordinate()
            let location = CLLocation(latitude: randomLat, longitude: randomLong)
            
            items.append(location)
            
        }
        
        return items
    }
}
