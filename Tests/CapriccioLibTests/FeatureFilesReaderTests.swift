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
        try? FileManager.default.removeItem(atPath: testFile4DesktopPath)
        super.tearDown()
    }
    
    func testItCanReadSingleFeatureFile() {
        write(fileContent: testFeatureFileWithoutTag(), toPath: testFile1Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path], includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 1
        expect(featureFiles[0].description) == "Google Searching"
        expect(featureFiles[0].scenarios.count) == 2
    }
    
    func testItCanReadMultipleFeatureFiles() {
        write(fileContent: testFeatureFileWithoutTag(), toPath: testFile1Path)
        write(fileContent: testFeatureFileWithTags(), toPath: testFile2Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path], includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 2
        expect(featureFiles[0].description) == "Google Searching"
        expect(featureFiles[0].scenarios.count) == 2
        expect(featureFiles[1].description) == "Verify billing"
        expect(featureFiles[1].scenarios.count) == 2
    }
    
    func testItCanReadMultipleFeatureFilesWithIncludedTags() {
        write(fileContent: testFeatureFileWithoutTag(), toPath: testFile1Path)
        write(fileContent: testFeatureFileWithTags(), toPath: testFile2Path)
        write(fileContent: testFeatureFileWithTag(), toPath: testFile3Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: ["fast"], excludedTags: nil)
        
        expect(featureFiles.count) == 1
        expect(featureFiles[0].description) == "Verify billing"
        expect(featureFiles[0].scenarios.count) == 2
        
        let featuresFiles2 = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: ["fast", "important"], excludedTags: nil)
        
        expect(featuresFiles2.count) == 2
        expect(featuresFiles2[0].description) == "Verify billing"
        expect(featuresFiles2[0].scenarios.count) == 2
        expect(featuresFiles2[1].scenarios.count) == 1
        expect(featuresFiles2[1].scenarios[0].description) == "Mario jumps"
    }
    
    func testItCanReadMultipleFeatureFilesWithExcludedTags() {
        write(fileContent: testFeatureFileWithoutTag(), toPath: testFile1Path)
        write(fileContent: testFeatureFileWithTags(), toPath: testFile2Path)
        write(fileContent: testFeatureFileWithTag(), toPath: testFile3Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: nil, excludedTags: ["fast"])
        
        expect(featureFiles.count) == 2
        expect(featureFiles[0].description) == "Google Searching"
        expect(featureFiles[1].description) == "SNES Mario Controls"
        
        let featuresFiles2 = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: nil, excludedTags: ["fast", "important"])
        
        expect(featuresFiles2.count) == 2
        expect(featuresFiles2[0].description) == "Google Searching"
        expect(featuresFiles2[0].scenarios.count) == 2
        expect(featuresFiles2[1].scenarios.count) == 1
        expect(featuresFiles2[1].scenarios[0].description) == "Star power"
    }
    
    func testItCanReadMultipleFeatureFilesWithIncludedAndExcludedTags() {
        write(fileContent: testFeatureFileWithoutTag(), toPath: testFile1Path)
        write(fileContent: testFeatureFileWithTags(), toPath: testFile2Path)
        write(fileContent: testFeatureFileWithTag(), toPath: testFile3Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: ["fast"], excludedTags: ["important"])
        
        expect(featureFiles.count) == 1
        expect(featureFiles[0].description) == "Verify billing"
        expect(featureFiles[0].scenarios.count) == 1
        expect(featureFiles[0].scenarios[0].description) == "Several products"
        
        let featuresFiles2 = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: ["important"], excludedTags: ["fast"])
        
        expect(featuresFiles2.count) == 1
        expect(featuresFiles2[0].description) == "SNES Mario Controls"
        expect(featuresFiles2[0].scenarios.count) == 1
        expect(featuresFiles2[0].scenarios[0].description) == "Mario jumps"
    }
    
    func testItCanReadMultipleFileNames() {
        write(fileContent: testFeatureFileWithoutTag(), toPath: testFile1Path)
        write(fileContent: testFeatureFileWithTags(), toPath: testFile2Path)
        write(fileContent: testFeatureFileWithTag(), toPath: testFile3Path)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile3Path], includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 3
        expect(featureFiles[0].fileName) == "Test1"
        expect(featureFiles[1].fileName) == "Test2"
        expect(featureFiles[2].fileName) == "Test3"
    }
    
    func testItCanReadMultipleFilesFromDifferentFolders() {
        write(fileContent: testFeatureFileWithoutTag(), toPath: testFile1Path)
        write(fileContent: testFeatureFileWithTags(), toPath: testFile2Path)
        write(fileContent: testFeatureFileWithTag(), toPath: testFile4DesktopPath)
        
        let featureFiles = featureFilesReader.readFiles(atPaths: [testFile1Path, testFile2Path, testFile4DesktopPath], includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 3
        expect(featureFiles[0].fileName) == "Test1"
        expect(featureFiles[1].fileName) == "Test2"
        expect(featureFiles[2].fileName) == "Test4"
    }
}

private extension FeatureFilesReaderTests {
    private var documentsPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                   .userDomainMask,
                                                   true).first! + "/"
    }
    
    private var desktopPath: String {
        return NSSearchPathForDirectoriesInDomains(.desktopDirectory,
                                                   .userDomainMask,
                                                   true).first! + "/"
    }
    
    private var testFile1Path: String {
        return documentsPath + "test1.feature"
    }
    
    private var testFile2Path: String {
        return documentsPath + "test2.feature"
    }
    
    private var testFile3Path: String {
        return documentsPath + "test3.feature"
    }
    
    private var testFile4DesktopPath: String {
        return desktopPath + "test4.feature"
    }
    
    private func testFeatureFileWithoutTag() -> String {
        return """
        Feature: Google Searching
        
        Scenario: Search website
        Given Google search results for "panda" are shown
        
        Scenario: Search image
        Given Google image results for "fox" are shown
        """
    }
    
    private func testFeatureFileWithTags() -> String {
        return """
        @fast
        Feature: Verify billing
        
        @important
        Scenario: Missing product description
        Given Missing product
        
        Scenario: Several products
        Given Products
        """
    }
    
    private func testFeatureFileWithTag() -> String {
        return """
        Feature: SNES Mario Controls
        
        @important
        Scenario: Mario jumps
        Given Mario not jumping
        
        Scenario: Star power
        Given Mario has powers
        """
    }
    
    private func write(fileContent: String, toPath path: String) {
        try! fileContent.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
