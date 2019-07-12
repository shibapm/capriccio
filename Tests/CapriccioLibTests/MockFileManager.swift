//
//  MockFileManager.swift
//  Capriccio
//
//  Created by Franco on 03/09/2018.
//

import TestSpy
@testable import CapriccioLib

final class MockFileManager: TestSpy, FileManaging {
    
    enum Method: Equatable {
        case contentsOfDirectory(path: String)
        case subpathsOfDirectory(path: String)
    }
    
    var callstack = CallstackContainer<Method>()
    
    var contentOfDirectoryResult: [String]!
    func contentsOfDirectory(atPath path: String) throws -> [String] {
        callstack.record(.contentsOfDirectory(path: path))
        return contentOfDirectoryResult
    }
    
    var subpathsOfDirectoryResult: [String]!
    func subpathsOfDirectory(atPath path: String) throws -> [String] {
        callstack.record(.subpathsOfDirectory(path: path))
        return subpathsOfDirectoryResult
    }
}
