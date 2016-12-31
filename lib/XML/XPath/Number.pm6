use v6.c;

use XML::XPath::Evaluable;
class XML::XPath::Number does XML::XPath::Evaluable {
    has Int $.value;
    method evaluate(XML::XPath::NodeSet $set, Bool $predicate, Str $axis = 'self') {
        my XML::XPath::NodeSet $result .= new;
        die "unexpected axis: $axis" unless $axis eq '' | 'self';
        for $set.nodes.kv -> $index, $node {
            $result.add($node) if $index + 1 == $.value;
        }

        return $result;
    }
}
