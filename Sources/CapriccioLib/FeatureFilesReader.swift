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
        let fileNames = paths.compactMap(getFileName)
        let filesContent = paths.compactMap { try? String(contentsOfFile: $0).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
        
        let newText: [String] = trimLines(from: filesContent)
        let gherkinFeatures = newText.compactMap { try? Gherkin.Feature($0) }
        var features = gherkinFeatures.compactMap(Feature.init)
        
        for i in 0..<fileNames.count {
            features[i] = features[i].withFileName(fileNames[i])
        }
        
        if includedTags != nil || excludedTags != nil {
            let includedTag = includedTags?.compactMap(Tag.init) ?? []
            let excludedTag = excludedTags?.compactMap(Tag.init) ?? []
            
            return filterFeatures(features: features, includedTags: includedTag, excludedTags: excludedTag)
        } else {
            return features
        }
    }
    
    private func filterFeatures(features: [Feature], includedTags: [Tag], excludedTags: [Tag]) -> [Feature] {
        return features.compactMap { feature -> Feature? in
            let scenarios = feature.scenarios.filter { scenario in
                let tags = scenario.tags
                
                let includedTagsCheck = includedTags.isEmpty || tags.contains(where: includedTags.contains)
                let excludedTagsCheck = !tags.contains(where: excludedTags.contains)
                
                return includedTagsCheck && excludedTagsCheck
            }
            
            return scenarios.count == 0 ?  nil : Feature(fileName: feature.fileName,
                                                         description: feature.description,
                                                         name: feature.name,
                                                         scenarios: scenarios,
                                                         tags: feature.tags)
        }
    }
    
    private func trimLines(from text: [String]) -> [String] {
        return text.compactMap { text in
            let lines = text.components(separatedBy: .newlines)
            
            let newLines: [String]  = lines.compactMap { line in
                let newLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if newLine.isEmpty { return nil }
                return newLine
            }
            
            return newLines.joined(separator: "\n")
        }
    }
    
    private func getFileName(from path: String) -> String? {
        if let regex = try? NSRegularExpression(pattern: "\\s?/[\\w\\s]*\\.feature", options: .caseInsensitive)
        {
            let string = path as NSString
            let fileName = regex.matches(in: path, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: ".feature", with: "").replacingOccurrences(of: "/", with: "").validEntityName()
            }
            
            return fileName.first
        }
        return nil
    }
}
