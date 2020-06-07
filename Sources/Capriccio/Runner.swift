//
//  Runner.swift
//
//
//  Created by Franco Meloni on 07/06/2020.
//

import CapriccioLib

enum Runner {
    static func run(with arguments: CapriccioArguments, filesFetcher: FeatureFilesFetcher) {
        let source = arguments.source
        let destination = arguments.destination

        let featureFiles = filesFetcher.featureFiles(atPath: source)

        let filesReader = FeatureFilesReader()
        let features = filesReader.readFiles(sourcePath: source, atPaths: featureFiles, includedTags: arguments.includedTags, excludedTags: arguments.excludedTags)

        let filesWriter = SwiftTestsFilesWriter()
        filesWriter.writeSwiftTest(fromFeatures: features, inFolder: destination, generatedClassType: arguments.generatedClassType, disableSwiftLint: arguments.disableSwiftLint, templateFilePath: arguments.templateFilePath, useSingleFile: arguments.useSingleFile, version: capriccioVersion)

        let filesCount = arguments.useSingleFile ? 1 : features.count

        print("Generated \(filesCount) \(filesCount == 1 ? "file" : "files") at \(destination)")

    }
}
