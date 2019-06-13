//
//  main.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Foundation
import Utility
import CapriccioLib

let capriccioVersion = "1.0.0"

let filesFetcher = FeatureFilesFetcher()

var arguments: CapriccioArguments
if let yamlPath = filesFetcher.yamlFile() {
    arguments = CapriccioArgumentsParser.parseArguments(yaml: yamlPath)
} else {
    arguments = CapriccioArgumentsParser.parseArguments()
}

let source = arguments.source
let destination = arguments.destination

let featureFiles = filesFetcher.featureFiles(atPath: source)

let filesReader = FeatureFilesReader()
let features = filesReader.readFiles(atPaths: featureFiles, includedTags: arguments.includedTags, excludedTags: arguments.excludedTags)

let filesWriter = SwiftTestsFilesWriter()
filesWriter.writeSwiftTest(fromFeatures: features, inFolder: destination, generatedClassType: arguments.generatedClassType, disableSwiftLint: arguments.disableSwiftLint, templateFilePath: arguments.templateFilePath, useSingleFile: arguments.useSingleFile, version: capriccioVersion)

let filesCount = arguments.useSingleFile ? 1 : features.count

print("Generated \(filesCount) \(filesCount == 1 ? "file" : "files") at \(destination)")
