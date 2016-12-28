use v6.c;
use XML::XPath::Expr;
use XML::XPath::NodeSet;
use XML::XPath::NodeTest;

class XML::XPath::Step {
    # TODO
    subset Axis of Str where {$_ ~~ <child self attribute descendant descendant-or-self>.any};

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
        if $.next {
            $result = $.next.evaluate($result);
        }

        return $result;
    }

    method !evaluate-node(XML::Node $node, XML::XPath::NodeSet $result) {
        given $.axis {
            when 'self' {
                $.test.test($node, $result);
            }
            when 'child' {
                for $node.nodes -> $child {
                    $.test.test($child, $result);
                }
            }
            default {
                X::NYI.new(feature => "axis $_").throw;
            }
        }

    }
}
