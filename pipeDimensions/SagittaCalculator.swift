//
//  SagittaCalculator.swift
//  pipeDimensions
//
//  Created on 2026-07-09.
//  Copyright © 2026 Nick Khotenko. All rights reserved.
//

import Foundation

/// Calculator for estimating NPS pipe size from sagitta and chord measurements
class SagittaCalculator {
    
    private let npsTable: [NPSEntry]
    
    /// Initializes calculator with NPS data from the diameter array
    /// - Parameter diameterArray: Array of diameter strings from DataManager
    init(diameterArray: [String]) {
        self.npsTable = Self.parseNPSTable(from: diameterArray)
    }
    
    // MARK: - Main Calculation
    
    /// Calculate estimated OD and find closest NPS matches
    /// - Parameters:
    ///   - sagitta: Height from chord to pipe arc
    ///   - chord: Width of visible pipe section
    ///   - unit: Measurement unit used
    /// - Returns: Complete estimation result with matches
    func calculate(sagitta: Double, chord: Double, unit: MeasurementUnit) -> NPSEstimationResult {
        // Validate inputs
        guard sagitta > 0, chord > 0 else {
            return NPSEstimationResult(
                sagittaMeasurement: sagitta,
                chordMeasurement: chord,
                unit: unit,
                estimatedOD: 0,
                matches: [],
                isSagittaFullDiameter: false,
                errorMessage: "Both measurements must be greater than zero"
            )
        }
        
        // Convert to inches for calculation
        let s = sagitta * unit.conversionToInches
        let c = chord * unit.conversionToInches
        let halfChord = c / 2.0
        
        // Special case: when sagitta >= chord, the contour tool fully surrounded the pipe
        // In this case, the chord IS the diameter
        let sagittaIsFullDiameter = s >= c
        
        // Validation: sagitta must be less than half chord for valid circular segment
        // (unless it's the full diameter case)
        if !sagittaIsFullDiameter && s >= halfChord {
            return NPSEstimationResult(
                sagittaMeasurement: sagitta,
                chordMeasurement: chord,
                unit: unit,
                estimatedOD: 0,
                matches: [],
                isSagittaFullDiameter: false,
                errorMessage: "⚠️ Invalid: Sagitta must be less than half the chord"
            )
        }
        
        // Calculate OD using circular segment formula
        // Formula: OD = 2 * (s² + (c/2)²) / (2s)
        // When sagitta ≥ chord: OD = chord (tool surrounded full pipe)
        let estimatedOD: Double
        if sagittaIsFullDiameter {
            estimatedOD = c  // Chord is the full diameter
        } else {
            estimatedOD = 2.0 * (s * s + halfChord * halfChord) / (2.0 * s)
        }
        
        // Find closest matches
        let matches = findClosestMatches(for: estimatedOD)
        
        return NPSEstimationResult(
            sagittaMeasurement: sagitta,
            chordMeasurement: chord,
            unit: unit,
            estimatedOD: estimatedOD,
            matches: matches,
            isSagittaFullDiameter: sagittaIsFullDiameter,
            errorMessage: nil
        )
    }
    
    // MARK: - NPS Matching
    
    /// Find the three closest NPS sizes (smaller, closest, larger)
    /// - Parameter od: Calculated outer diameter in inches
    /// - Returns: Array of up to 3 matches (may be less at extremes)
    private func findClosestMatches(for od: Double) -> [NPSMatch] {
        guard !npsTable.isEmpty else { return [] }
        
        // Find the closest match
        var closestIndex = 0
        var minDelta = Double.infinity
        
        for (index, entry) in npsTable.enumerated() {
            let delta = abs(entry.odInches - od)
            if delta < minDelta {
                minDelta = delta
                closestIndex = index
            }
        }
        
        var matches: [NPSMatch] = []
        
        // Add smaller size (if exists)
        if closestIndex > 0 {
            let entry = npsTable[closestIndex - 1]
            matches.append(NPSMatch(
                npsEntry: entry,
                deltaInches: entry.odInches - od,
                matchType: .smaller
            ))
        }
        
        // Add closest match
        let closestEntry = npsTable[closestIndex]
        matches.append(NPSMatch(
            npsEntry: closestEntry,
            deltaInches: closestEntry.odInches - od,
            matchType: .closest
        ))
        
        // Add larger size (if exists)
        if closestIndex < npsTable.count - 1 {
            let entry = npsTable[closestIndex + 1]
            matches.append(NPSMatch(
                npsEntry: entry,
                deltaInches: entry.odInches - od,
                matchType: .larger
            ))
        }
        
        return matches
    }
    
    // MARK: - NPS Table Parsing
    
    /// Parse NPS table from diameter array strings
    /// Format: "NPS  ODmm mm ODin in" e.g., "1/2  21.3 mm 0.840 in"
    private static func parseNPSTable(from diameterArray: [String]) -> [NPSEntry] {
        // Regex to match: "NPS  ODmm mm ODin in"
        let pattern = #"^(.+?)\s{2,}([\d.]+)\s*mm\s+([\d.]+)\s*in"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        var results: [NPSEntry] = []
        
        // Skip first entry (header) and parse rest
        for diameterString in diameterArray.dropFirst() {
            let nsString = diameterString as NSString
            let range = NSRange(location: 0, length: nsString.length)
            
            if let match = regex.firstMatch(in: diameterString, range: range) {
                let npsLabel = nsString.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
                let odMm = Double(nsString.substring(with: match.range(at: 2))) ?? 0
                let odIn = Double(nsString.substring(with: match.range(at: 3))) ?? 0
                
                results.append(NPSEntry(label: npsLabel, odIn: odIn, odMm: odMm))
            }
        }
        
        return results
    }
}
