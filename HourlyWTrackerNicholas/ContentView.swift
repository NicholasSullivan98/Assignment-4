//
//  ContentView.swift
//  Assignment4
//
//  Created by Nicholas Sullivan on 2024-11-26.
//  ID: 991612414

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject var locationManager = MyLocationManager()
    @State var camPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var locationName = "" // search locations of interest
    @State var selection: MKMapItem? // selected Marker
    
    var body: some View {
        VStack {
            Text("Hourly Weather App")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            TextField("Enter City", text: $locationName)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
            
            Button("Search") {
                locationManager.getCoordinates(for: locationName)
            }
            
            if let weather = locationManager.weather, let location = weather.location {
                Text("\(location.name), \(location.region), \(location.country)")
                    .font(.title)
                    .padding(.top, 20)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Time")
                            .font(.headline)
                            .frame(width: 75, alignment: .leading) // Adjust the width of the Time column
                        Text("Temp")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Con")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Hum")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Rain %")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    
                    if let forecast = weather.forecast?.forecastday.first {
                        let next7Hours = filterNext7Hours(from: forecast.hour)
                        
                        ForEach(next7Hours, id: \.time_epoch) { hour in
                            HStack {
                                Text(formatTime(hour.time))
                                    .fontWeight(isCurrentHour(hour.time) ? .bold : .regular)
                                    .foregroundColor(isCurrentHour(hour.time) ? .blue : .black)
                                    .frame(width: 75, alignment: .leading) // Adjust the width of the Time column
                                Text("\(String(format: "%.1f", hour.temp_c))°C")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                AsyncImage(url: URL(string: "https:\(hour.condition.icon)")) { image in
                                    image.resizable()
                                        .frame(width: 32, height: 32)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(hour.humidity)%")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(hour.chance_of_rain)%")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text("No forecast data available.")
                            .padding(.top, 20)
                    }
                }
                .padding(.top, 10)
            } else {
                Text("Fetching weather data...")
                    .padding(.top, 20)
            }
        }
        .padding()
    }
    
    func formatTime(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString
        }
    }
    
    func filterNext7Hours(from hours: [Hour]) -> [Hour] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let next7Hours = hours.filter { hour in
            if let date = getDate(from: hour.time) {
                return calendar.isDate(date, equalTo: currentDate, toGranularity: .day) && (date >= calendar.date(byAdding: .hour, value: -1, to: currentDate)!)
            }
            return false
        }.prefix(7)
        
        return Array(next7Hours)
    }
    
    func getDate(from dateString: String) -> Date? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return inputFormatter.date(from: dateString)
    }
    
    func isCurrentHour(_ dateString: String) -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        
        if let date = getDate(from: dateString) {
            return calendar.isDate(date, equalTo: currentDate, toGranularity: .hour)
        }
        return false
    }
}

#Preview {
    ContentView()
}



