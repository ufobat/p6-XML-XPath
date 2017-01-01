use v6.c;

use XML::XPath::Evaluable;
use XML::XPath::Types;

class XML::XPath::Number does XML::XPath::Evaluable {
    has Int $.value;

    multi method evaluate(XML::XPath::NodeSet $set, XML::Node $node, Bool $predicate, Axis :$axis = 'self', Int :$index) {
        die "unexpected axis: $axis" unless $axis eq '' | 'self';
        my XML::XPath::NodeSet $result .= new;
        $result.add($node) if $index + 1 == $.value;
        return $result;
    }
    multi method evaluate(XML::XPath::NodeSet $set, Bool $predicate, Axis :$axis = 'self', Int :$index) {
        die "unexpected axis: $axis" unless $axis eq '' | 'self';
        my XML::XPath::NodeSet $result .= new;
        for $set.nodes.kv -> $index, $node {
            $result.add: self.evaluate($set, $node, $predicate, :$index);
        }
    }
}
