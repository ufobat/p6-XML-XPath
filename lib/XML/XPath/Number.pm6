use v6.c;

use XML::XPath::Testable;
class XML::XPath::Number does XML::XPath::Testable {
    has Int $.value;
    method test(XML::XPath::NodeSet $set, XML::XPath::NodeSet $result, Str $axis = 'self') {
        die "unexpected axis: $axis" unless $axis eq '' | 'self';
        for $set.nodes.kv -> $index, $node {
            $result.add($node) if $index + 1 == $.value;
        }
    }
}
