import Foundation

import XCTest

final class CodeGen: XCTestCase {
    
    // NOT A TEST: actually runs code generation
    func testCodeGen() throws {

        let fileManager = FileManager.default
        let testsPath = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent()
        
        let repoPath = testsPath.deletingLastPathComponent()
        let sourcesPath = repoPath.appendingPathComponent("Sources")
        print(repoPath)
        print(sourcesPath)
        
        let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
        let enumerator = FileManager.default.enumerator(at: sourcesPath, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles, .skipsPackageDescendants])!

        for case let fileURL as URL in enumerator {
            let resourceValues = try! fileURL.resourceValues(forKeys: Set(resourceKeys))
            if resourceValues.isDirectory! {
                continue
            }
            
            let fileContents = try! String(contentsOf: fileURL, encoding: .utf8)
            
            // https://regex101.com/r/Tmnf2G/1
            let pattern = #"\/\/ cg:start\n((?!\/\/ cg:end)(.|\n))*\/\/ cg:end"#
            let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
            
            let stringRange = NSRange(location: 0, length: fileContents.utf16.count)
            let substitutionString = """
            // cg:start
            GABE
            // cg:end
            """
            let result = regex.stringByReplacingMatches(in: fileContents, range: stringRange, withTemplate: substitutionString)
            
            try! result.write(to: fileURL, atomically: false, encoding: .utf8)
            
            print(fileURL.lastPathComponent)
        }
        
    }
}


