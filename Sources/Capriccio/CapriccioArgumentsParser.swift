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
        let sourceArgument: PositionalArgument<String> = parser.add(positional: "source", kind: String.self, usage: "The path to the folder that contains the feature files")
        let destinationArgument: PositionalArgument<String> = parser.add(positional: "destination", kind: String.self, usage: "The path to the folder where the swift files will be generated")
        
        let excludedTagsOption: OptionArgument<String> = parser.add(option: "--excluded-tags", shortName: "-e", kind: String.self, usage: "The list of excluded tags separated by a comma", completion: nil)
        
        let parsedArguments = try? parser.parse(arguments)
        
        guard let source = parsedArguments?.get(sourceArgument) else {
            fatalError("Missing source")
        }

        guard let destination = parsedArguments?.get(destinationArgument) else {
            fatalError("Missing destination")
        }
        
        let excludedTags = parsedArguments?.get(excludedTagsOption)?.components(separatedBy: ",")
        
        return CapriccioArguments(source: source, destination: destination, excludedTags: excludedTags)
    }
}
