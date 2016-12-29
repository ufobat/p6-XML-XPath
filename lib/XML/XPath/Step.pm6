use v6.c;
use XML::XPath::NodeSet;
use XML::XPath::NodeTest;
use XML::XPath::Evaluable;

class XML::XPath::Step does XML::XPath::Evaluable {
    # TODO
    subset Axis of Str where {$_ ~~ <child self attribute descendant descendant-or-self namespace>.any};

    has Axis $.axis is rw is required;
    has XML::XPath::NodeTest $.test is required;
    has @.predicates;
    has XML::XPath::Step $.next is rw;

    method evaluate(XML::XPath::NodeSet $set) {
        my $result = XML::XPath::NodeSet.new;
        if $.axis {
            for $set.nodes -> $node {
                self!evaluate-node($node, $result);
            }
        } else {
            die 'this should never happen';
        }

        for @.predicates -> $predicate {
            $result = $predicate.evaluate($result);
        }

        if $.next {
            $result = $.next.evaluate($result);
        }

        return $result;
    }

    method !evaluate-node(XML::Node $node, XML::XPath::NodeSet $result) {
        given $.axis {
            when 'self' {
                $.test.test(0, $node, $result);
            }
            when 'child' {
                for $node.nodes.kv -> $i, $child {
                    $.test.test($i, $child, $result);
                }
            }
            when 'descendant' {
                self!walk-descendant($node, $result);
            }
            when 'descendant-or-self' {
                $.test.test(0, $node, $result);
                self!walk-descendant($node, $result);
            }
            default {
                X::NYI.new(feature => "axis $_").throw;
            }
        }
    }

    method !walk-descendant(XML::Node $node, XML::XPath::NodeSet $result) {
        return unless $node.^can('nodes');
        for $node.nodes.kv -> $i, $child {
            $.test.test($i, $child, $result);
            self!walk-descendant($child, $result);
        }
    }
}
