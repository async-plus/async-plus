import Foundation

import XCTest

extension String {
    
    var fullRange: NSRange {
        return NSRange(location: 0, length: self.utf16.count)
    }
    
    /// Returns capture groups for each match
    func regexFind(_ pattern: String) -> [[String]] {
        
        let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
        let matches: [NSTextCheckingResult] = regex.matches(in: self, range: fullRange)
        
        return matches.map {
            match in
            return (0..<match.numberOfRanges).map {
                i in
                let rangeBounds = match.range(at: i)
                let range = Range(rangeBounds, in: self)!
                return String(self[range])
            }
        }
    }
    
    func replacingRegex(_ pattern: String, with: String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
        return regex.stringByReplacingMatches(in: self, range: fullRange, withTemplate: with)
    }
    
    func splitOnUnescapedComma() -> [String] {
        let noCollisionForComma = "C$@CoMmM4A"
        let safeStr = self.replacingOccurrences(of: #"\,"#, with: noCollisionForComma, options: .literal, range: nil)
        return safeStr.components(separatedBy: ", ").map {
            $0.replacingOccurrences(of: noCollisionForComma, with: ",", options: .literal, range: nil)
        }
    }
}

final class CodeGen: XCTestCase {
    
    func runCodeGen(_ sourceStr: String, _ ruleSets: [String: String]) -> String {
        
        var definedPatterns: [String: String] = [:]
        
        // Look for patterns
        for captureGroups in sourceStr.regexFind(#"\/\/ pattern:([\w\d]+)\n((?:(?!\/\/ endpattern).|\n)*)\/\/ endpattern"#) {
            let patternName = captureGroups[1]
            let pattern = captureGroups[2]
            definedPatterns[patternName] = pattern
        }
        
        // Determine what to codegen
        var codeGenStrs: [String] = []
        for captureGroups in sourceStr.regexFind(#"\/\/ generate:([\w\d]+)\((.*)\)"#) {
            
            let patternName = captureGroups[1]
            let substitutionRules = captureGroups[2]
            guard let patternBody = definedPatterns[patternName] else {
                fatalError("Unknown pattern name \(patternName)")
            }
            
            // Commas within substitution rules need to be escaped with \,
            let rulesSplit = substitutionRules.splitOnUnescapedComma()
            
            var bodyWithSubs = patternBody
            var rulesExpandedWithRuleSets: [String] = []
            for keyOrRule: String in rulesSplit {
                if let sub: String = ruleSets[keyOrRule] {
                    rulesExpandedWithRuleSets += sub.splitOnUnescapedComma()
                } else {
                    rulesExpandedWithRuleSets.append(keyOrRule)
                }
            }
            
            for rule in rulesExpandedWithRuleSets {
                
                let parts = rule.components(separatedBy: " => ")
                let lhs = parts[0]
                let rhs = parts[1]
                bodyWithSubs = bodyWithSubs.replacingOccurrences(of: "// \(lhs)\n", with: rhs + "\n")
                bodyWithSubs = bodyWithSubs.replacingOccurrences(of: "/* \(lhs) */", with: rhs)
                bodyWithSubs = bodyWithSubs.replacingOccurrences(of: lhs, with: rhs)
            }
            
            codeGenStrs.append(bodyWithSubs)
        }
        
        // Output with codegen
        let replaceWith = """
        // GENERATED
        \(codeGenStrs.joined(separator: "\n"))// END GENERATED
        """
        return sourceStr.replacingRegex(#"\/\/ GENERATED\n((?!\/\/ END GENERATED)(.|\n))*\/\/ END GENERATED"#, with: replaceWith)
    }
    
    func forEverySourceFile(_ closure: (URL) -> ()) {
        
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
            
            closure(fileURL)
        }
    }

    func getRuleSets() -> [String: String] {
        var ruleSets: [String: String] = [:]
        forEverySourceFile {
            fileURL in
            
            // Read file
            let fileContents = try! String(contentsOf: fileURL, encoding: .utf8)
            
            for captureGroups in fileContents.regexFind(#"\/\/ ruleset:([\w\d]+)\((.*)\)"#) {
                
                let ruleSetName = captureGroups[1]
                let substitutionRules = captureGroups[2]
                ruleSets[ruleSetName] = substitutionRules
            }
        }
        return ruleSets
    }
    
    // NOT A TEST: Actually runs code generation! Commit first!
    func testCodeGen() throws {

        let ruleSets = getRuleSets()
        
        forEverySourceFile {
            fileURL in
            
            // Read file
            let fileContents = try! String(contentsOf: fileURL, encoding: .utf8)
            
            // Scan top level declaration. We rely on this repo having proper indentation levels for this to work.
            // TLD is a term used loosely
            var transformedTLDs: [String] = []
            var runningTLD = ""
            
            for line in fileContents.components(separatedBy: .newlines) {
                
                if line.starts(with: "}") {
                    if runningTLD.contains("// generate:") &&  !runningTLD.contains("// GENERATED") {
                        runningTLD += "\n    // GENERATED\n    // END GENERATED\n"
                    }
                    runningTLD += line + "\n"
                    transformedTLDs.append(runCodeGen(runningTLD, ruleSets))
                    runningTLD = ""
                } else {
                    runningTLD += line + "\n"
                }
            }
            transformedTLDs.append(runCodeGen(runningTLD, ruleSets))
            
            // Write file (dropLast \n)
            try! transformedTLDs.joined(separator: "").dropLast().write(to: fileURL, atomically: false, encoding: .utf8)
        }
        
        print("DONE")
    }
}


