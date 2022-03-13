import Foundation

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
