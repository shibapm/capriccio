//
//  FeatureFilesReader.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Foundation
import Gherkin

public struct Metadata {
    let fileName: String
    let path: String
    let feature: Feature
}

public final class FeatureFilesReader {
    public init() { }
    
    public func readFiles(sourcePath: String, atPaths paths: [String], includedTags: [String]?, excludedTags: [String]?) -> [Metadata] {
        let metadata = paths.map(fileMetadata)
        
        let filesContent = paths.compactMap { try? String(contentsOfFile: sourcePath + "/" + $0).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
        let texts: [String] = trimLines(from: filesContent)
        
        let textAndMetadata = zip(texts, metadata)
        let metadatas = textAndMetadata.compactMap { (text, metadata) -> Metadata? in
            guard let gherkinFeature = try? Gherkin.Feature(text) else {
                print("Unable to parse the file: \(metadata.name) at \(metadata.path)")
                return nil
            }
            
            let feature = Feature(gherkinFeature: gherkinFeature)
            let metadata = Metadata(fileName: metadata.name, path: metadata.path, feature: feature)
            return metadata
        }
        
        if includedTags != nil || excludedTags != nil {
            let includedTag = includedTags?.compactMap(Tag.init) ?? []
            let excludedTag = excludedTags?.compactMap(Tag.init) ?? []
            
            return filterFeatures(metadatas: metadatas, includedTags: includedTag, excludedTags: excludedTag)
        } else {
            return metadatas
        }
    }
    
    private func filterFeatures(metadatas: [Metadata], includedTags: [Tag], excludedTags: [Tag]) -> [Metadata] {
        return metadatas.compactMap { metadata -> Metadata? in
            let scenarios = metadata.feature.scenarios.filter { scenario in
                let tags = scenario.tags
                
                let includedTagsCheck = includedTags.isEmpty || tags.contains(where: includedTags.contains)
                let excludedTagsCheck = !tags.contains(where: excludedTags.contains)
                
                return includedTagsCheck && excludedTagsCheck
            }
            
            guard scenarios.count != 0 else {
                return nil
            }
            
            let feature = Feature(description: metadata.feature.description,
                                  name: metadata.feature.name,
                                  scenarios: scenarios,
                                  tags: metadata.feature.tags)
            
            return Metadata(fileName: metadata.fileName, path: metadata.path, feature: feature)
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
    
    private func fileMetadata(from path: String) -> (name: String, path: String) {
        let pathName = path.replacingOccurrences(of: ".feature", with: "").replacingOccurrences(of: "/", with: " ")
        let outputPath = path.components(separatedBy: "/").dropLast().joined(separator: "/") + "/"
        
        let words = pathName.split(separator: " ")
        let filteredWords = Array(NSOrderedSet(array: words)) as? [String.SubSequence]
        
        let name = filteredWords?.map { word in
            return word.prefix(1).uppercased() + word.dropFirst()
            }.joined(separator: "_")
        
        guard let fileName = name else {
            return (name: words.joined(separator: "_"), path: outputPath)
        }
        
        return (name: fileName, path: outputPath)
    }
}
