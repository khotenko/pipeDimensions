//
//  SagittaModels.swift
//  pipeDimensions
//
//  Created on 2026-07-09.
//  Copyright © 2026 Nick Khotenko. All rights reserved.
//

import Foundation

// MARK: - NPS Entry

/// Represents a standard NPS pipe size with its dimensions
struct NPSEntry {
    let npsLabel: String        // e.g., "1/2", "2-1/2", "6"
    let odInches: Double        // Outer diameter in inches
    let odMillimeters: Double   // Outer diameter in millimeters
    
    init(label: String, odIn: Double, odMm: Double) {
        self.npsLabel = label
        self.odInches = odIn
        self.odMillimeters = odMm
    }
}

// MARK: - Unit Type

/// Measurement unit for the estimation tool
enum MeasurementUnit {
    case inches
    case millimeters
    
    var symbol: String {
        switch self {
        case .inches: return "in"
        case .millimeters: return "mm"
        }
    }
    
    var conversionToInches: Double {
        switch self {
        case .inches: return 1.0
        case .millimeters: return 1.0 / 25.4
        }
    }
}

// MARK: - NPS Match

/// Represents a potential NPS match with its deviation from calculated OD
struct NPSMatch {
    let npsEntry: NPSEntry
    let deltaInches: Double      // Difference from calculated OD
    let matchType: MatchType
    
    enum MatchType {
        case smaller    // Next size down
        case closest    // Best match
        case larger     // Next size up
    }
    
    var isClosest: Bool {
        return matchType == .closest
    }
    
    /// Returns formatted delta string in the specified unit
    func formattedDelta(in unit: MeasurementUnit) -> String {
        let delta = abs(deltaInches)
        switch unit {
        case .inches:
            return "±\(String(format: "%.3f", delta)) in"
        case .millimeters:
            return "±\(String(format: "%.1f", delta * 25.4)) mm"
        }
    }
}

// MARK: - Estimation Result

/// Complete result of the sagitta-based OD estimation
struct NPSEstimationResult {
    let sagittaMeasurement: Double      // Input sagitta value
    let chordMeasurement: Double        // Input chord value
    let unit: MeasurementUnit           // Unit used for inputs
    let estimatedOD: Double             // Calculated OD in inches
    let matches: [NPSMatch]             // [smaller, closest, larger]
    let isSagittaFullDiameter: Bool     // True when S ≥ C
    let errorMessage: String?           // Validation error if any
    
    /// Whether the estimation is valid
    var isValid: Bool {
        return errorMessage == nil
    }
    
    /// Returns formatted OD in the specified unit
    func formattedOD(in unit: MeasurementUnit) -> String {
        switch unit {
        case .inches:
            return "\(String(format: "%.3f", estimatedOD)) in"
        case .millimeters:
            return "\(String(format: "%.1f", estimatedOD * 25.4)) mm"
        }
    }
}
