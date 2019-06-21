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
    private var paths: Paths!
    
    override func setUp() {
        super.setUp()
        featureFilesReader = FeatureFilesReader()
        writeAllFiles()
    }
    
    override func tearDown() {
        featureFilesReader = nil
        removeAllFiles()
        super.tearDown()
    }
    
    func testItCanReadSingleFeatureFile() {
        let featureFiles = featureFilesReader.readFiles(sourcePath: paths.single.folder, atPaths: paths.single.files, includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 1
        expect(featureFiles[0].feature.description) == "Google Searching"
        expect(featureFiles[0].feature.scenarios.count) == 2
    }
    
    func testItCanReadMultipleFeatureFiles() {
        let sortedFiles = paths.all.files.sorted()
        let featureFiles = featureFilesReader.readFiles(sourcePath: paths.all.folder, atPaths: sortedFiles, includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 3
        expect(featureFiles[0].feature.description) == "Verify billing"
        expect(featureFiles[0].feature.scenarios.count) == 2
        expect(featureFiles[1].feature.description) == "Google Searching"
        expect(featureFiles[1].feature.scenarios.count) == 2
        expect(featureFiles[2].feature.description) == "SNES Mario Controls"
        expect(featureFiles[2].feature.scenarios.count) == 2
    }
    
    func testItCanReadMultipleFeatureFilesWithIncludedTags() {
        let sortedFiles = paths.all.files.sorted()
        let featureFiles = featureFilesReader.readFiles(sourcePath: paths.all.folder, atPaths: sortedFiles, includedTags: ["fast"], excludedTags: nil)
        
        expect(featureFiles.count) == 1
        expect(featureFiles[0].feature.description) == "Verify billing"
        expect(featureFiles[0].feature.scenarios.count) == 2
        
        let featuresFiles2 = featureFilesReader.readFiles(sourcePath: paths.all.folder, atPaths: sortedFiles, includedTags: ["fast", "important"], excludedTags: nil)
        
        expect(featuresFiles2.count) == 2
        expect(featuresFiles2[0].feature.description) == "Verify billing"
        expect(featuresFiles2[0].feature.scenarios.count) == 2
        expect(featuresFiles2[1].feature.scenarios.count) == 1
        expect(featuresFiles2[1].feature.scenarios[0].description) == "Mario jumps"
    }
    
    func testItCanReadMultipleFeatureFilesWithExcludedTags() {
        let sortedFiles = paths.all.files.sorted()
        let featureFiles = featureFilesReader.readFiles(sourcePath: paths.all.folder, atPaths: sortedFiles, includedTags: nil, excludedTags: ["fast"])
        
        expect(featureFiles.count) == 2
        expect(featureFiles[0].feature.description) == "Google Searching"
        expect(featureFiles[1].feature.description) == "SNES Mario Controls"
        
        let featuresFiles2 = featureFilesReader.readFiles(sourcePath: paths.all.folder, atPaths: sortedFiles, includedTags: nil, excludedTags: ["fast", "important"])
        
        expect(featuresFiles2.count) == 2
        expect(featuresFiles2[0].feature.description) == "Google Searching"
        expect(featuresFiles2[0].feature.scenarios.count) == 2
        expect(featuresFiles2[1].feature.scenarios.count) == 1
        expect(featuresFiles2[1].feature.scenarios[0].description) == "Star power"
    }
    
    func testItCanReadMultipleFeatureFilesWithIncludedAndExcludedTags() {
        let sortedFiles = paths.all.files.sorted()
        let featureFiles = featureFilesReader.readFiles(sourcePath: paths.all.folder, atPaths: sortedFiles, includedTags: ["fast"], excludedTags: ["important"])
        
        expect(featureFiles.count) == 1
        expect(featureFiles[0].feature.description) == "Verify billing"
        expect(featureFiles[0].feature.scenarios.count) == 1
        expect(featureFiles[0].feature.scenarios[0].description) == "Several products"
        
        let featuresFiles2 = featureFilesReader.readFiles(sourcePath: paths.all.folder, atPaths: sortedFiles, includedTags: ["important"], excludedTags: ["fast"])
        
        expect(featuresFiles2.count) == 1
        expect(featuresFiles2[0].feature.description) == "SNES Mario Controls"
        expect(featuresFiles2[0].feature.scenarios.count) == 1
        expect(featuresFiles2[0].feature.scenarios[0].description) == "Mario jumps"
    }
    
    func testItCanReadMultipleFileNames() {
        let sortedFiles = paths.all.files.sorted()
        let featureFiles = featureFilesReader.readFiles(sourcePath: paths.all.folder, atPaths: sortedFiles, includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 3
        expect(featureFiles[0].fileName) == "Billing"
        expect(featureFiles[1].fileName) == "Google"
        expect(featureFiles[2].fileName) == "Mario"
    }
    
    func testItCanReadMultipleFilesFromDifferentFolders() {
        let sortedFiles = paths.nested.files.sorted()
        let featureFiles = featureFilesReader.readFiles(sourcePath: paths.nested.folder, atPaths: sortedFiles, includedTags: nil, excludedTags: nil)
        
        expect(featureFiles.count) == 3
        expect(featureFiles[0].fileName) == "Billing"
        expect(featureFiles[1].fileName) == "Mario"
        expect(featureFiles[2].fileName) == "Search_Google"
    }
}

private extension FeatureFilesReaderTests {
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
    
    private struct Paths {
        let single: (folder: String, files: [String])
        let all: (folder: String, files: [String])
        let nested: (folder: String, files: [String])
    }
    
    private var documentsPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/"
    }
    
    private var rootPath: String {
        return "capriccioFeaturesTest/"
    }
    
    private func writeAllFiles() {
        
        /**
         | capriccioFeaturesTest
         | - single
         | - - google.feature
         | - all
         | - - billing.feature
         | - - google.feature
         | - - mario.feature
         | - nested
         | - - mario.feature
         | - - search
         | - - - google.feature
         | - - billing
         | - - - billing.feature
         */
        
        let rootFolder = documentsPath + rootPath
        let single = rootFolder + "single/"
        let all = rootFolder + "all/"
        let nested = rootFolder + "nested/"
        let nestedSearch = nested + "search/"
        let nestedBilling = nested + "billing/"
        
        let folders = [single, all, nestedSearch, nestedBilling]
        for folder in folders {
            try! FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
        }
        
        let mario = (path: "mario.feature", code: testFeatureFileWithTag())
        let billing = (path: "billing.feature", code: testFeatureFileWithTags())
        let google = (path: "google.feature", code: testFeatureFileWithoutTag())
        
        let singleFeature = [
            (path: single + google.path, code: google.code)
        ]
        
        let allFeatures = [
            (path: all + google.path, code: google.code),
            (path: all + mario.path, code: mario.code),
            (path: all + billing.path, code: billing.code)
        ]
        
        let nestedFeatures = [
            (path: nestedSearch + google.path, code: google.code),
            (path: nested + mario.path, code: mario.code),
            (path: nestedBilling + billing.path, code: billing.code)
        ]
        
        var features = singleFeature
        features.append(contentsOf: allFeatures)
        features.append(contentsOf: nestedFeatures)
        
        for feature in features {
            try! feature.code.write(toFile: feature.path, atomically: true, encoding: .utf8)
        }
        
        self.paths = Paths(single: (folder: single, files: singleFeature.map { remove(folder: single, from: $0.0) }),
                           all: (folder: all, files: allFeatures.map { remove(folder: all, from: $0.0) }),
                           nested: (folder: nested, files: nestedFeatures.map { remove(folder: nested, from: $0.0) }))
    }
    
    private func removeAllFiles() {
        let rootFolder = documentsPath + rootPath
        try! FileManager.default.removeItem(atPath: rootFolder)
    }
    
    private func remove(folder: String, from feature: String) -> String {
        return feature.replacingOccurrences(of: folder, with: "")
    }
}
