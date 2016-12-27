use v6.c;
use XML::XPath::Expr;
use XML::XPath::NodeSet;

class XML::XPath::Step {
    # TODO
    subset Axis of Str where {$_ ~~ <child self attribute>.any};
    #subset Test of Str where {$_ ~~ any<>};-+

    has Axis $.axis is rw;
    has Str $.test;
    has Str $.literal;
    has @.predicates;
    has XML::XPath::Step $.next is rw;

    method evaluate(XML::XPath::NodeSet $set) {
        my $result = XML::XPath::NodeSet.new;
        if $.axis and $.literal {
            for $set.nodes -> $element {
                self!evaluate-element($element, $result);
            }
        } else {
            die 'this should never happen';
        }
        if $.next {
            $result = $.next.evaluate($result);
        }

        return $result;
    }

    method !evaluate-element(XML::Element $element, XML::XPath::NodeSet $result) {
        given $.axis {
            when 'self' {
                if $element.name eq $.literal {
                    $result.add($element);
                } else {
                    die "elementname: { $element.name } literal: {$.literal} did not match";
                }
            }
            when 'child' {
                for $element.nodes -> $child {
                    if $child ~~ XML::Element {
                        $result.add($child) if $child.name eq $.literal;
                    }
                }
            }
            default {
                X::NYI.new(feature => "axis $_").throw;
            }
        }

    }
}
