//
//  HourlyWTrackerNicholasWidget.swift
//  HourlyWTrackerNicholasWidget
//
//  Created by Nicholas Sullivan on 2024-11-26.
//

import WidgetKit
import SwiftUI
import Intents

struct WeatherEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let temperature: Double
    let icon: UIImage
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), cityName: "Cupertino", temperature: 20.00, icon: UIImage(systemName: "photo")!)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WeatherEntry {
        await fetchWeatherEntry(for: configuration.cityName)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WeatherEntry> {
        var entries: [WeatherEntry] = []
        let cityName = configuration.cityName

        let weatherData = await fetchWeatherEntries(for: cityName)
        
        entries.append(contentsOf: weatherData)
        
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func fetchImage(from url: URL) async -> UIImage? {
        let session = URLSession(configuration: .default)
        do {
            let (data, _) = try await session.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to fetch image: \(error.localizedDescription)")
                return nil
        }
    }

    private func fetchWeatherEntry(for city: String) async -> WeatherEntry {
        let vm = MyLocationManager()
        let iconPlaceholder = UIImage(systemName: "photo")!
        var weatherEntry: WeatherEntry = WeatherEntry(date: Date(), cityName: city, temperature: 20.00, icon: iconPlaceholder)

        let semaphore = DispatchSemaphore(value: 0)
        
        vm.getCoordinates(for: city)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            guard let weather = vm.weather, let forecast = weather.forecast?.forecastday.first else {
                semaphore.signal()
                return
            }

            let firstHour = forecast.hour.first!
            let iconURLString = "https:\(firstHour.condition.icon)"
            Task {
                if let iconURL = URL(string: iconURLString), let icon = await self.fetchImage(from: iconURL) {
                    print("Icon URL: \(iconURL)") // Debug print
                    weatherEntry = WeatherEntry(date: Date(), cityName: weather.location?.name ?? "null", temperature: round(firstHour.temp_c * 100) / 100.0, icon: icon)
                } else {
                    print("Failed to create URL from string: \(iconURLString)")
                }
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return weatherEntry
    }

    private func fetchWeatherEntries(for city: String) async -> [WeatherEntry] {
        let vm = MyLocationManager()
        let iconPlaceholder = UIImage(systemName: "photo")!
        var weatherEntries: [WeatherEntry] = []

        let semaphore = DispatchSemaphore(value: 0)
        
        vm.getCoordinates(for: city)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            guard let weather = vm.weather, let forecastDay = weather.forecast?.forecastday.first else {
                semaphore.signal()
                return
            }

            let currentDate = Date()
            let group = DispatchGroup()
            
            for (index, hour) in forecastDay.hour.prefix(7).enumerated() {
                let iconURLString = "https:\(hour.condition.icon)"
                group.enter()
                Task {
                    if let iconURL = URL(string: iconURLString), let icon = await self.fetchImage(from: iconURL) {
                        print("Icon URL: \(iconURL)") // Debug print
                        let entry = WeatherEntry(date: Calendar.current.date(byAdding: .hour, value: index, to: currentDate)!, cityName: weather.location?.name ?? "null", temperature: round(hour.temp_c * 100) / 100.0, icon: icon)
                        weatherEntries.append(entry)
                    } else {
                        print("Failed to create URL from string: \(iconURLString)")
                        let entry = WeatherEntry(date: Calendar.current.date(byAdding: .hour, value: index, to: currentDate)!, cityName: weather.location?.name ?? "null", temperature: round(hour.temp_c * 100) / 100.0, icon: iconPlaceholder)
                        weatherEntries.append(entry)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return weatherEntries
    }
}

struct HourlyWTrackerNicholasWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.cityName)
                .font(.headline)
            Text("\(String(format: "%.0f", entry.temperature))°")
                .font(.title)
            Image(uiImage: entry.icon)
                .resizable()
                .frame(width: 30, height: 30,alignment: .leading)
            Text(entry.date, style: .time)
                .font(.subheadline)
        }
    }
}

struct HourlyWTrackerNicholasWidget: Widget {
    let kind: String = "HourlyWTrackerNicholasWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            HourlyWTrackerNicholasWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Weather Widget")
        .description("Displays hourly weather information.")
    }
}

#Preview(as: .systemSmall) {
    HourlyWTrackerNicholasWidget()
} timeline: {
    WeatherEntry(date: .now, cityName: "Cupertino", temperature: 22.00, icon: UIImage(systemName: "photo")!)
}





