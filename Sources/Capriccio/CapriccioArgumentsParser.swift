//
//  CapriccioArgumentsParser.swift
//  Capriccio
//
//  Created by Franco on 05/09/2018.
//
import Foundation
import Yams

final class CapriccioArgumentsParser {
    static func parseArguments(yaml yamlPath: String) -> CapriccioArguments {
        let yamlFile = try? String(contentsOfFile: yamlPath)
        
        let directoryContents: [String: Any]
        do {
            directoryContents = try Yams.load(yaml: yamlFile ?? "") as! [String: Any]
        } catch {
            fatalError("Unable to load YAML file: .capriccio.yml")
        }
        
        guard let source = directoryContents["source"] as? String else {
            fatalError("Missing source")
        }
        
        guard let output = directoryContents["output"] as? String else {
            fatalError("Missing output")
        }
        
        let excludedTags = directoryContents["excludedTags"] as? [String]
        let includedTags = directoryContents["includedTags"] as? [String]
        let generatedClassType = directoryContents["classType"] as? String
        let useSingleFile = directoryContents["singleFile"] as? Bool ?? false
        let disableSwiftLint = directoryContents["disableSwiftLint"] as? Bool ?? false
        let templateFile = directoryContents["template"] as? String
        
        return CapriccioArguments(source: source,
                                  destination: output,
                                  excludedTags: excludedTags,
                                  includedTags: includedTags,
                                  generatedClassType: generatedClassType,
                                  useSingleFile: useSingleFile,
                                  disableSwiftLint: disableSwiftLint,
                                  templateFilePath: templateFile)
    }
}
