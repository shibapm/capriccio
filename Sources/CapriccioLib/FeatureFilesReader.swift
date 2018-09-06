//
//  FeatureFilesReader.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Foundation
import Gherkin

public final class FeatureFilesReader {
    public init() { }
    
    public func readFiles(atPaths paths: [String], includedTags: [String]?, excludedTags: [String]?) -> [Feature] {
        let filesContent = paths.compactMap { try? String(contentsOfFile: $0).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
        let features = filesContent.compactMap { try! Feature($0) }
        
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
                let tags = scenario.tags ?? []
                
                let includedTagsCheck = includedTags.isEmpty || tags.contains { includedTags.contains($0.name) }
                let excludedTagsCheck = !tags.contains { excludedTags.contains($0.name) }
                
                return includedTagsCheck && excludedTagsCheck
            }
            
            return scenarios.count == 0 ?  nil : Feature(name: feature.name, description: feature.textDescription, scenarios: scenarios)
        }
    }
}
