use v6.c;
use XML::Node;
use XML::XPath::NodeSet;

role XML::XPath::Testable {
    method test(Int $index, XML::Node $node, XML::XPath::NodeSet $result) { ... }
}
