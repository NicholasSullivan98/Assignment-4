//
//  MyLocationManager.swift
//  Assignment4
//
//  Created by Nicholas Sullivan on 2024-11-26.
//  ID: 991612414

import Foundation
import CoreLocation
import MapKit
import Combine

class MyLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var location: CLLocation = CLLocation()
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.4561, longitude: -79.7000),
                                               span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))

    @Published var mapItems: [MKMapItem] = []
    @Published var mkRoute: MKRoute?
    @Published var weather: Weather?
    @Published var geocodingError: String? // Add this property

    let manager = CLLocationManager()
    let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()  // Continuously update location
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("location error")
            return
        }
        print("lat: \(location.coordinate.latitude) , lng: \(location.coordinate.longitude)")
        self.location = location
        getWeather(for: location.coordinate)  // Fetch weather whenever location updates
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("location services are available")
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            print("not determined")
        case .restricted, .denied:
            print("location services are restricted/denied")
        default:
            print("default")
        }
    }

    let baseUrlStr = "https://api.weatherapi.com/v1/forecast.json?key=7ec9ca3cd0304e50bfd203630241311"

    func getWeather(for coordinate: CLLocationCoordinate2D) {
        let urlStr = baseUrlStr + "&q=" + String(coordinate.latitude) + "," + String(coordinate.longitude)
        print(urlStr)
        guard let url = URL(string: urlStr) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let err = error {
                print("error \(err)")
                //self.geocodingError = "Error fetching weather data"
            } else if let data = data {
                //self.geocodingError = nil
                do {
                    let jsondecoder = JSONDecoder()
                    let weatherResponse = try jsondecoder.decode(Weather.self, from: data)

                    DispatchQueue.main.async {
                        self.weather = weatherResponse
                    }
                } catch {
                    print("error \(error)")
                }
            }
        }
        task.resume()
    }

    func getCoordinates(for cityName: String) {
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            if let err = error {
                print("Geocoding error: \(err)")
                self.geocodingError = "Location does not exist"
            } else if let placemark = placemarks?.first, let location = placemark.location {
                let coordinate = location.coordinate
                print("Coordinates for \(cityName): \(coordinate.latitude), \(coordinate.longitude)")
                self.getWeather(for: coordinate)
                self.geocodingError = nil 
            }
        }
    }
}


/*
import Foundation
import CoreLocation
import MapKit
import Combine

class MyLocationManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var location: CLLocation = CLLocation()
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.4561, longitude: -79.7000),
                                               span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    
    @Published var mapItems: [MKMapItem] = []
    @Published var mkRoute: MKRoute?
    @Published var weather: Weather?
    
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()  // Continuously update location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("location error")
            return
        }
        print("lat: \(location.coordinate.latitude) , lng: \(location.coordinate.longitude)")
        self.location = location
        getWeather(for: location.coordinate)  // Fetch weather whenever location updates
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("location services are available")
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            print("not determined")
        case .restricted, .denied:
            print("location services are restricted/denied")
        default:
            print("default")
        }
    }
    
    let baseUrlStr = "https://api.weatherapi.com/v1/forecast.json?key=7ec9ca3cd0304e50bfd203630241311"
    
    func getWeather(for coordinate: CLLocationCoordinate2D) {
        let urlStr = baseUrlStr + "&q=" + String(coordinate.latitude) + "," + String(coordinate.longitude)
        print(urlStr)
        guard let url = URL(string: urlStr) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let err = error {
                print("error \(err)")
            } else if let data = data {
                do {
                    let jsondecoder = JSONDecoder()
                    let weatherResponse = try jsondecoder.decode(Weather.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.weather = weatherResponse
                    }
                } catch {
                    print("error \(error)")
                }
            }
        }
        task.resume()
    }
    
    func getCoordinates(for cityName: String) {
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            if let err = error {
                print("Geocoding error: \(err)")
            } else if let placemark = placemarks?.first, let location = placemark.location {
                let coordinate = location.coordinate
                print("Coordinates for \(cityName): \(coordinate.latitude), \(coordinate.longitude)")
                self.getWeather(for: coordinate)
            }
        }
    }
}
*/
