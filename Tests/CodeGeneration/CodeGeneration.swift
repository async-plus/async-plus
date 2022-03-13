import Foundation

import XCTest

let debugRulesInComments = false

enum MappingType: CaseIterable {
    case normal
    case optional
    case regex
    case optionalRegex
    
    var symbol: String {
        switch self {
        case .normal:
            return "=>"
        case .optional:
            return "?=>"
        case .regex:
            return "R=>"
        case .optionalRegex:
            return "R?=>"
        }
    }
    
    var isOptional: Bool {
        switch self {
        case .optional, .optionalRegex:
            return true
        case .normal, .regex:
            return false
        }
    }
    
    var isRegex: Bool {
        switch self {
        case .regex, .optionalRegex:
            return true
        case .normal, .optional:
            return false
        }
    }
}

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
        var previousRules: [String]? = nil
        for captureGroups in sourceStr.regexFind(#"\/\/ generate:([\w\d]+)\((.*)\)"#) {
            
            let patternName = captureGroups[1]
            let substitutionRules = captureGroups[2]
            guard let patternBody = definedPatterns[patternName] else {
                fatalError("Unknown pattern name \(patternName)")
            }
            
            // Commas within substitution rules need to be escaped with \,
            var rules = substitutionRules.splitOnUnescapedComma()
            let rulesCopy = rules
            
            var bodyWithSubs = patternBody

            while !rules.isEmpty {
                let rule = rules.removeFirst()
                
                var parts: [String] = []
                var matchedMappingType: MappingType? = nil
                for mappingType: MappingType in MappingType.allCases {
                    parts = rule.components(separatedBy: " \(mappingType.symbol) ")
                    if parts.count == 2 {
                        matchedMappingType = mappingType
                        break
                    } else if parts.count > 2 {
                        fatalError("Found consecutive '=>' or similar mappings: need ', ' to separate them.")
                    }
                }
                
                guard let matchedMappingType = matchedMappingType else {
                    // Expand this as a ruleset
                    if rule == "..." {
                        guard let previousRules = previousRules else {
                            fatalError("Usage of ... requires previous statement of '// generate' defined in the same top-level declaration.")
                        }
                        rules = previousRules + rules
                    } else if let sub: String = ruleSets[rule] {
                        rules = sub.splitOnUnescapedComma() + rules
                    } else if rule.contains("->") {
                        fatalError("Use ' => ' not ' -> ' to make rules.")
                    } else {
                        fatalError("Could not find referenced ruleset: \(rule)")
                    }

                    continue
                }
                let lhs = parts[0]
                let rhs = parts[1]
                
                var newBodyWithSubs = bodyWithSubs
                if !matchedMappingType.isRegex {
                    newBodyWithSubs = newBodyWithSubs.replacingOccurrences(of: "// \(lhs)\n", with: rhs + "\n")
                    newBodyWithSubs = newBodyWithSubs.replacingOccurrences(of: "/* \(lhs) */", with: rhs)
                    newBodyWithSubs = newBodyWithSubs.replacingOccurrences(of: lhs, with: rhs)
                } else {
                    newBodyWithSubs = newBodyWithSubs.replacingRegex(lhs, with: rhs)
                }
                
                if !matchedMappingType.isOptional && newBodyWithSubs == bodyWithSubs {
                    fatalError("Rule \(rule) did not match any part of the input pattern. Mark the rule as optional with ?=> or R?=> if this is expected.")
                }
                bodyWithSubs = newBodyWithSubs
            }
            previousRules = rulesCopy
            let toAppend: String
            if debugRulesInComments {
                toAppend = """
                    // Generated from \(patternName) (\(substitutionRules))
                \(bodyWithSubs)
                """
            } else {
                toAppend = """
                    // Generated from \(patternName)
                \(bodyWithSubs)
                """
            }
            
            codeGenStrs.append(toAppend)
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
            
            // Safety checks
            if fileContents.contains("// endPattern") {
                fatalError("The proper directive is '// endpattern' (no capitalization)")
            }
            if fileContents.contains("//pattern") || fileContents.contains("//ruleset") || fileContents.contains("//generate") {
                fatalError("Need space before code gen directive.")
            }
            
            
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


