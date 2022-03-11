import Foundation

protocol Node {
    associatedtype IntOrString
}

// Any node can produce int nodes...
protocol CanProduceIntNode: Node {
    
    associatedtype IntNode: Node where
    IntNode.IntOrString == Int
    
    func produceIntNode() -> IntNode
}

// ... but only string nodes can produce more string nodes
protocol CanProduceStringNode: Node where IntOrString == String {

    associatedtype StringNode: Node where
    StringNode.IntOrString == String

    func produceStringNode() -> StringNode
}

// Make a generic class that conforms to Node, and CanProduceIntNode
class GenericNode<IntOrString>: Node, CanProduceIntNode {
    
    typealias IntNode = GenericNode<Int>

    func produceIntNode() -> IntNode {
        return IntNode()
    }
}

// Comment the below out for a passing build
extension GenericNode: CanProduceStringNode where IntOrString == String {
    typealias StringNode = GenericNode<String>
    
    func produceStringNode() -> StringNode {
        return StringNode()
    }
}
