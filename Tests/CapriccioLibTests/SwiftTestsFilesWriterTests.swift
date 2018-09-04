//
//  SwiftTestsFilesWriterTests.swift
//  CapriccioLibTests
//
//  Created by Franco on 04/09/2018.
//

import XCTest
import Foundation
import Nimble
import Gherkin
@testable import CapriccioLib

final class SwiftTestsFilesWriterTests: XCTestCase {
    private var swiftTestsFilesWriter: SwiftTestsFilesWriter!
    private var stubbedSwiftTestCodeGenerating: StubbedSwiftTestCodeGenerating!
    
    let testFolder = NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                         .userDomainMask, true).first!
    
    var generatedFilesPaths: [String]!
    
    override func setUp() {
        super.setUp()
        generatedFilesPaths = []
        
        stubbedSwiftTestCodeGenerating = StubbedSwiftTestCodeGenerating()
        stubbedSwiftTestCodeGenerating.result = "Code"
        swiftTestsFilesWriter = SwiftTestsFilesWriter(swiftCodeGenerator: stubbedSwiftTestCodeGenerating)
    }
    
    override func tearDown() {
        stubbedSwiftTestCodeGenerating = nil
        swiftTestsFilesWriter = nil
        generatedFilesPaths?.forEach { try? FileManager.default.removeItem(atPath: $0) }
        super.tearDown()
    }
    
    func testItWritesTheCorrectFileForAFeature() {
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [])
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature], inFolder: testFolder)
        
        let filePath = self.filePath(forFeature: feature)
        generatedFilesPaths?.append(filePath)
        
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == "Code"
    }
    
    func testItWritesTheCorrectFileForMultipleFeatures() {
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [])
        
        let feature2 = Feature(name: "Feature number two",
                              description: "",
                              scenarios: [])
        
        swiftTestsFilesWriter.writeSwiftTest(fromFeatures: [feature, feature2], inFolder: testFolder)
        
        let filePath = self.filePath(forFeature: feature)
        generatedFilesPaths?.append(filePath)
        
        expect(FileManager.default.fileExists(atPath: filePath)) == true
        expect(try? String(contentsOfFile: filePath)) == "Code"
        
        let file2Path = self.filePath(forFeature: feature2)
        generatedFilesPaths?.append(file2Path)
        
        expect(FileManager.default.fileExists(atPath: file2Path)) == true
        expect(try? String(contentsOfFile: file2Path)) == "Code"
    }
    
    private func filePath(forFeature feature: Feature) -> String {
        return testFolder + "/" + feature.name.camelCased(upper: true) + ".swift"
    }
}

private class StubbedSwiftTestCodeGenerating: SwiftTestCodeGenerating {
    var result: String!
    
    func generateSwiftTestCode(forFeature feature: Feature) -> String {
        return result
    }
}
