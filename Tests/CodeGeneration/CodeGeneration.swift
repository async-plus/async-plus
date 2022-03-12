import Foundation

import XCTest

func runCodeGen(_ fileContents: String) -> String {
    let fileRange = NSRange(location: 0, length: fileContents.utf16.count)
    
    func submatchesToString(match: NSTextCheckingResult) -> [String] {
        return (0..<match.numberOfRanges).map {
            i in
            let rangeBounds = match.range(at: i)
            let range = Range(rangeBounds, in: fileContents)!
            return String(fileContents[range])
        }
    }
    
    var cgPatterns: [String: String] = [:]
    
    // Look for pattern's
    let pattern1 = #"\/\/ pattern:([\w\d]+)\n((?:(?!\/\/ endpattern).|\n)*)\/\/ endpattern"#
    let regex1 = try! NSRegularExpression(pattern: pattern1, options: .anchorsMatchLines)
    let matches: [NSTextCheckingResult] = regex1.matches(in: fileContents, range: fileRange)
    
    for match: NSTextCheckingResult in matches {
        let submatches: [String] = submatchesToString(match: match)
        cgPatterns[submatches[1]] = submatches[2]
    }
    
    // Determine what to codegen
    var codeGen = ""
    let pattern2 = #"\/\/ generate:([\w\d]+)\(((?:\\\)|[^\)])*)\)"#
    let regex2 = try! NSRegularExpression(pattern: pattern2, options: .anchorsMatchLines)
    let matches2: [NSTextCheckingResult] = regex2.matches(in: fileContents, range: fileRange)
    for match in matches2 {
        let submatches = submatchesToString(match: match)
        let cgPatternName = submatches[1]
        let substitutionRules = submatches[2]
        guard let cgPatternBody = cgPatterns[cgPatternName] else {
            fatalError("Unknown pattern name \(cgPatternName)")
        }
        
        // Commas within substitution rules need to be escaped with \,
        let noCollisionForComma = "C$@CoMmM4A"
        let safeSubs = substitutionRules.replacingOccurrences(of: #"\,"#, with: noCollisionForComma, options: .literal, range: nil)
        let rulesSplit = safeSubs.components(separatedBy: ", ").map {
            $0.replacingOccurrences(of: noCollisionForComma, with: ",", options: .literal, range: nil)
        }
        
        var bodyWithSubs = cgPatternBody
        for rule in rulesSplit {
            let parts = rule.components(separatedBy: " => ")
            let lhs = parts[0]
            let rhs = parts[1]
            bodyWithSubs = bodyWithSubs.replacingOccurrences(of: lhs, with: rhs)
        }
        
        codeGen += bodyWithSubs + "\n"
    }
    
    // Output with codegen
    let pattern = #"\/\/ GENERATED\n((?!\/\/ END GENERATED)(.|\n))*\/\/ END GENERATED"#
    let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
    
    let substitutionString = """
    // GENERATED
    \(codeGen)    // END GENERATED
    """
    return regex.stringByReplacingMatches(in: fileContents, range: fileRange, withTemplate: substitutionString)
}

final class CodeGen: XCTestCase {
    
    // NOT A TEST: actually runs code generation
    func testCodeGen() throws {

        // Find source files
        let testsPath = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent()
        
        let repoPath = testsPath.deletingLastPathComponent()
        let sourcesPath = repoPath.appendingPathComponent("Sources")
        print(repoPath)
        print(sourcesPath)
        
        let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
        let enumerator = FileManager.default.enumerator(at: sourcesPath, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles, .skipsPackageDescendants])!

        // Loop over all source files
        for case let fileURL as URL in enumerator {
            let resourceValues = try! fileURL.resourceValues(forKeys: Set(resourceKeys))
            if resourceValues.isDirectory! {
                continue
            }
            
            // Read file
            let fileContents = try! String(contentsOf: fileURL, encoding: .utf8)
            
            // Scan top level declaration. We rely on this repo having proper indentation levels for this to work.
            var result = ""
            var runningTLD = ""
            
            func finishTLD(_ line: String) {

            }
            
            for line in fileContents.components(separatedBy: .newlines) {
                
                if line.starts(with: "}") {
                    if runningTLD.contains("// generate:") &&  !runningTLD.contains("// GENERATED") {
                        runningTLD += "\n    // GENERATED\n    // END GENERATED\n"
                    }
                    runningTLD += line + "\n"
                    result += runCodeGen(runningTLD)
                    runningTLD = ""
                } else {
                    runningTLD += line + "\n"
                }
            }
            result += runCodeGen(runningTLD)
            
            // Write file
            try! result.dropLast().write(to: fileURL, atomically: false, encoding: .utf8)
        }
        
        print("DONE")
    }
}


