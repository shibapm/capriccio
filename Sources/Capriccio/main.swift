//
//  main.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Foundation
import Utility
import CapriccioLib

let argumets = CapriccioArgumentsParser.parseArguments()

let source = argumets.source
let destination = argumets.destination

let filesFetcher = FeatureFilesFetcher()
let featureFiles = filesFetcher.featureFiles(atPath: source)

let filesReader = FeatureFilesReader()
let features = filesReader.readFiles(atPaths: featureFiles, includedTags: argumets.includedTags, excludedTags: argumets.excludedTags)

let filesWriter = SwiftTestsFilesWriter()
filesWriter.writeSwiftTest(fromFeatures: features, inFolder: destination)

print("Generated \(features.count) \(features.count == 1 ? "file" : "files") at \(destination)")
