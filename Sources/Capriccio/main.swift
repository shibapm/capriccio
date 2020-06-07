//
//  main.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import Foundation
import CapriccioLib

let capriccioVersion = "1.1.0"

let filesFetcher = FeatureFilesFetcher()

var arguments: CapriccioArguments
if let yamlPath = filesFetcher.yamlFile(),
    !CommandLine.arguments.contains("--help") {
    Runner.run(with: CapriccioArgumentsParser.parseArguments(yaml: yamlPath), filesFetcher: filesFetcher)
} else {
    ArgumentsRunner.main()
}
