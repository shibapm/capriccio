//
//  FeatureFilesReaderTests.swift
//  CapriccioLibTests
//
//  Created by Franco on 03/09/2018.
//

import XCTest
import Foundation
import Nimble
@testable import CapriccioLib

final class FeatureFilesReaderTests: XCTestCase {
    var featureFilesReader: FeatureFilesReader!
    
    override func setUp() {
        super.setUp()
        featureFilesReader = FeatureFilesReader()
    }
    
    override func tearDown() {
        featureFilesReader = nil
        try? FileManager.default.removeItem(atPath: testFile1Path)
        try? FileManager.default.removeItem(atPath: testFile2Path)
        try? FileManager.default.removeItem(atPath: testFile3Path)
        super.tearDown()
    }
    
    func testItCanReadSingleFeatureFile() {
        write(fileContent: testFeatureFile1Content(), toPath: testFile1Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path], includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 1
        expect(featureFiles[0].name) == "Test Scenario"
    }
    
    func testItCanReadMultipleFeatureFiles() {
        write(fileContent: testFeatureFile1Content(), toPath: testFile1Path)
        write(fileContent: testFeatureFile2Content(), toPath: testFile2Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path], includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 2
        expect(featureFiles[0].name) == "Test Scenario"
        expect(featureFiles[1].name) == "Test Scenario 2"
    }
    
    func testItCanReadMultipleFeatureFilesWithIncludedTags() {
        write(fileContent: testFeatureFile1Content(), toPath: testFile1Path)
        write(fileContent: testFeatureFile2Content(), toPath: testFile2Path)
        write(fileContent: testFeatureFile3Content(), toPath: testFile3Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: ["included"], excludedTags: nil)
        
        expect(featureFiles.count) == 2
        expect(featureFiles[0].name) == "Test Scenario 2"
        expect(featureFiles[1].name) == "Test Scenario 3"
    }
    
    func testItCanReadMultipleFeatureFilesWithdExcludedTags() {
        write(fileContent: testFeatureFile1Content(), toPath: testFile1Path)
        write(fileContent: testFeatureFile2Content(), toPath: testFile2Path)
        write(fileContent: testFeatureFile3Content(), toPath: testFile3Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: nil, excludedTags: ["excluded"])
        
        expect(featureFiles.count) == 2
        expect(featureFiles[0].name) == "Test Scenario"
        expect(featureFiles[1].name) == "Test Scenario 2"
    }
    
    func testItCanReadMultipleFeatureFilesWithIncludedAndExcludedTags() {
        write(fileContent: testFeatureFile1Content(), toPath: testFile1Path)
        write(fileContent: testFeatureFile2Content(), toPath: testFile2Path)
        write(fileContent: testFeatureFile3Content(), toPath: testFile3Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: ["included"], excludedTags: ["excluded"])
        
        expect(featureFiles.count) == 1
        expect(featureFiles[0].name) == "Test Scenario 2"
    }
}

private extension FeatureFilesReaderTests {
    private var testFile1Path: String {
        return NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                   .userDomainMask, true).first! + "test1.feature"
    }
    
    private var testFile2Path: String {
        return NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                            .userDomainMask, true).first! + "test2.feature"
    }
    
    private var testFile3Path: String {
        return NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                   .userDomainMask, true).first! + "test3.feature"
    }
    
    private func testFeatureFile1Content() -> String {
        return """
        Feature: Test Scenario
        
        Scenario: test scenario
        Given I have to do a test
        And I'm a developer
        """
    }
    
    private func testFeatureFile2Content() -> String {
        return """
        Feature: Test Scenario 2
        
        @included
        Scenario: test scenario 2
        Given I have to do another test
        And I'm the same developer i was before
        """
    }
    
    private func testFeatureFile3Content() -> String {
        return """
        Feature: Test Scenario 3
        
        @included @excluded
        Scenario: test scenario 3
        Given I have to do another test
        And I will use it just for tags
        """
    }
    
    private func write(fileContent: String, toPath path: String) {
        try! fileContent.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
