use v6.c;

use XML::XPath::Testable;
class XML::XPath::Number does XML::XPath::Testable {
    has Int $.value;
    method test(Int $index, XML::Node $node, XML::XPath::NodeSet $result) {
        # nodes in xpath start with 1
        $result.add($node) if $index + 1 == $.value;
    }
}
