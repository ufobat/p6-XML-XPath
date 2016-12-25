use v6.c;
use XML::XPath::Expr;
use XML::XPath::NodeSet;

class XML::XPath::Step is XML::XPath::Expr {
    # TODO
    subset Axis of Str where {$_ ~~ <child self>.any};
    #subset Test of Str where {$_ ~~ any<>};

    # from Expr;
    # has $.expression is rw;
    # has $.operator is rw;
    # has $.next;
    # has @.predicates;

    has Axis $.axis is rw;
    has Str $.test;
    has Str $.literal;

    method evaluate(XML::XPath::NodeSet $set) {
        if $.expression and $.operator {
            # in Step the $.operator belongs to $.expression
            X::NYI.new(feature => 'Step Evaluation for expression and operator').throw;
        } elsif $.axis and $.literal {
            my $result = XML::XPath::NodeSet.new;
            for $set.nodes -> $element {
                self!evaluate-element($element, $result);
            }
            return $result;
        } else {
            die 'this should never happen';
        }
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
            #when 'child' {
            #}
            default {
                X::NYI.new(feature => "axis $_ not implemented").throw;
            }
        }

    }
}
