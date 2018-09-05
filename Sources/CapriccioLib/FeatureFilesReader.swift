//
//  FeatureFilesReader.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Foundation
import Gherkin

        let filesContent = paths.compactMap { try? String(contentsOfFile: $0) }
        let features = filesContent.compactMap { try? Feature($0) }
public final class FeatureFilesReader {
    public init() { }
    
    public func readFiles(atPaths paths: [String], includedTags: [String]?, excludedTags: [String]?) -> [Feature] {
        
        if includedTags != nil ||
            excludedTags != nil {
            return filterFeatures(features: features, includedTags: includedTags, excludedTags: excludedTags)
        } else {
            return features
        }
    }
    
    private func filterFeatures(features: [Feature], includedTags: [String]?, excludedTags: [String]?) -> [Feature] {
        let includedTags = includedTags ?? []
        let excludedTags = excludedTags ?? []
        
        return features.compactMap { feature -> Feature? in
            let scenarios = feature.scenarios.filter { scenario in
                scenario.tags.contains { includedTags.contains($0.tagName) } && !scenario.tags.contains { excludedTags.contains($0.tagName) }
            }
            
            return scenarios.count == 0 ?  nil : Feature(name: feature.name, description: feature.textDescription, scenarios: scenarios)
        }
    }
}
