//
//  AppIntent.swift
//  HourlyWTrackerNicholasWidget
//
//  Created by Nicholas Sullivan on 2024-11-26.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Weather Configuration" }
    static var description: IntentDescription { "Configure the widget to show weather information for your chosen city." }

    @Parameter(title: "City Name", default: "Cupertino")
    var cityName: String
}

