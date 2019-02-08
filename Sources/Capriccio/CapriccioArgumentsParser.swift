//
//  CapriccioArgumentsParser.swift
//  Capriccio
//
//  Created by Franco on 05/09/2018.
//
import Foundation
import Utility

final class CapriccioArgumentsParser {
    static func parseArguments() -> CapriccioArguments {
        let arguments = Array(CommandLine.arguments.dropFirst())
        
        let parser = ArgumentParser(usage: "<options>", overview: "Create UI Tests from feature files")
        
        let sourceArgument = parser.add(positional: "source", kind: String.self, usage: "The path to the folder that contains the feature files")
        
        let destinationArgument = parser.add(positional: "destination", kind: String.self, usage: "The path to the folder where the swift files will be generated")
        
        let excludedTagsOption = parser.add(option: "--excluded-tags", shortName: "-e", kind: String.self, usage: "The list of excluded tags separated by a comma", completion: nil)
        
        let includedTagsOption = parser.add(option: "--included-tags", shortName: "-i", kind: String.self, usage: "The list of included tags separated by a comma", completion: nil)
        
        let generatedClassTypeOption = parser.add(option: "--class-type", shortName: "-c", kind: String.self, usage: "The class type of the generated class [default value XCTestCase]", completion: nil)
        
        let useSingleFileOption = parser.add(option: "--single-file", shortName: "-s", kind: Bool.self, usage: "Generates a single swift file with the content of all the feature files", completion: nil)
        
        let disableSwiftLintOption = parser.add(option: "--disable-swiflint", shortName: "-l", kind: Bool.self, usage: "Disables swiftlint on the file", completion: nil)
        
        let templateFileOption = parser.add(option: "--template-file", shortName: "-t", kind: String.self, usage: "Path to the stencil template file", completion: nil)
        
        let parsedArguments = try? parser.parse(arguments)

        guard let source = parsedArguments?.get(sourceArgument) else {
            fatalError("Missing source")
        }

        guard let destination = parsedArguments?.get(destinationArgument) else {
            fatalError("Missing destination")
        }
        
        let excludedTags = parsedArguments?.get(excludedTagsOption)?.components(separatedBy: ",")
        let includedTags = parsedArguments?.get(includedTagsOption)?.components(separatedBy: ",")
        let generatedClassType = parsedArguments?.get(generatedClassTypeOption)
        let useSingleFile = parsedArguments?.get(useSingleFileOption) ?? false
        let disableSwiftLint = parsedArguments?.get(disableSwiftLintOption) ?? false
        let templateFile = parsedArguments?.get(templateFileOption)
        
        return CapriccioArguments(source: source, destination: destination, excludedTags: excludedTags, includedTags: includedTags, generatedClassType: generatedClassType, useSingleFile: useSingleFile, disableSwiftLint: disableSwiftLint, templateFilePath: templateFile)
    }
}
