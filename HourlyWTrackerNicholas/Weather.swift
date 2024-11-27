//
//  Weather.swift
//  Assignment4
//
//  Created by Nicholas Sullivan on 2024-11-26.
//  ID: 991612414


import Foundation

// Root model renamed to Weather
struct Weather: Codable {
    let location: Location?
    let current: Current
    let forecast: Forecast?
}

// Location model
struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
}

// Condition model
struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}

// Current weather model
struct Current: Codable {
    let temp_c: Double
    let condition: Condition
    let humidity: Int
}

// Forecast day model without Astro
struct ForecastDay: Codable {
    let date: String
    let hour: [Hour]
}

// Hour model
struct Hour: Codable {
    let time_epoch: Int
    let time: String
    let temp_c: Double
    let condition: Condition
    let humidity: Int
    let will_it_rain: Int
    let chance_of_rain: Int
}

// Forecast model
struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

