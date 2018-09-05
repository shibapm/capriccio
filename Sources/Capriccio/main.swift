//
//  main.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Foundation
import Utility
import CapriccioLib

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let parser = ArgumentParser(usage: "source destination <options>", overview: "Create UI Tests from feature files")
let sourceArgument: PositionalArgument<String> = parser.add(positional: "source", kind: String.self, usage: "The path to the folder that contains the feature files")
let destinationArgument: PositionalArgument<String> = parser.add(positional: "destination", kind: String.self, usage: "The path to the folder where the swift files will be generated")

let parsedArguments = try parser.parse(arguments)

guard let source = parsedArguments.get(sourceArgument) else {
    fatalError("Missing source")
}

guard let destination = parsedArguments.get(destinationArgument) else {
    fatalError("Missing destination")
}

let filesFetcher = FeatureFilesFetcher()
let featureFiles = filesFetcher.featureFiles(atPath: source)

let filesReader = FeatureFilesReader()
let features = filesReader.readFiles(atPaths: featureFiles, includedTags: nil, excludedTags: nil)

let filesWriter = SwiftTestsFilesWriter()
filesWriter.writeSwiftTest(fromFeatures: features, inFolder: destination)

print("Generated \(features.count) \(features.count == 1 ? "file" : "files") at \(destination)")
