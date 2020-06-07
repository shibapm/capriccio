//
//  ArgumentsRunner.swift
//  
//
//  Created by Franco Meloni on 07/06/2020.
//

import ArgumentParser

struct ArgumentsRunner: ParsableCommand {
    @Argument(help: "The path to the folder that contains the feature files")
    var source: String
    @Argument(help: "The path to the folder where the swift files will be generated")
    var destination: String
    @Option(name: [.customShort("e"), .customLong("excluded-tags")], help: "The list of excluded tags separated by a comma")
    var excludedTags: String?
    @Option(name: [.customShort("i"), .customLong("included-tags")], help: "The list of included tags separated by a comma")
    var includedTags: String?
    @Option(name: [.customShort("c"), .customLong("class-type")], help: "The list of included tags separated by a comma")
    var generatedClassType: String?
    @Flag(name: [.customShort("s"), .customLong("single-file")], help: "Generates a single swift file with the content of all the feature files")
    var useSingleFile: Bool
    @Flag(name: [.customShort("l"), .customLong("disable-swiftlint")], help: "Disables swiftlint on the file")
    var disableSwiftLint: Bool
    @Option(name: [.customShort("t"), .customLong("template-file")], help: "Path to the stencil template file")
    var templateFilePath: String?

    mutating func run() throws {
        let arguments  = CapriccioArguments(source: source,
                                            destination: destination,
                                            excludedTags: excludedTags?.components(separatedBy: ",") ?? [],
                                            includedTags: includedTags?.components(separatedBy: ",") ?? [],
                                            generatedClassType: generatedClassType,
                                            useSingleFile: useSingleFile,
                                            disableSwiftLint: disableSwiftLint,
                                            templateFilePath: templateFilePath)
        
        Runner.run(with: arguments, filesFetcher: filesFetcher)
    }
}
