use v6.c;
use XML::XPath::NodeSet;
use XML::XPath::NodeTest;
use XML::XPath::Evaluable;
use XML::XPath::Types;

class XML::XPath::Step does XML::XPath::Evaluable {
    has Axis $.axis is rw is required;
    has XML::XPath::NodeTest $.test = XML::XPath::NodeTest.new;
    has @.predicates;
    has XML::XPath::Step $.next is rw;

    multi method evaluate(XML::XPath::NodeSet $set, XML::Node $node, Bool $predicate, Axis :$axis = 'self', Int :$index) {
        return self!evaluate($node, $predicate, $axis, $index, :$set);
    }
    multi method evaluate(XML::XPath::NodeSet $set, Bool $predicate, Axis :$axis = 'self', Int :$index) {
        return self!evaluate($set, $predicate, $axis, $index);
    }

    method !evaluate($what, Bool $predicate, Axis $str, Int $index, :$set) {
        my XML::XPath::NodeSet $result;
        if $.axis {
            $result = $set
            ?? $.test.evaluate($set, $what, $predicate, :$.axis, :$index)
            !! $.test.evaluate($what, $predicate, :$.axis);
        } else {
            die 'this should never happen';
        }

        for @.predicates {
            my $interim = XML::XPath::NodeSet.new();
            for $result.nodes.kv -> $index, $node {
                $interim.add: $_.evaluate($result, $node, True, :$index);
            }
            $result = $interim;
        }

        if $.next {
            $result = $.next.evaluate($result, $predicate, :$index);
        }
        return $result;
    }
}
