use v6.c;
use XML::XPath::Result::ResultList;
use XML::XPath::NodeTest;
use XML::XPath::Evaluable;
use XML::XPath::Types;

class XML::XPath::Step does XML::XPath::Evaluable {
    has Axis $.axis is rw is required;
    has XML::XPath::NodeTest $.test = XML::XPath::NodeTest.new;
    has @.predicates;
    has XML::XPath::Step $.next is rw;

    method evaluate(XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        my XML::XPath::Result $result;
        if $.axis {
            $result = $.test.evaluate($set, :$.axis, :$index).trim: :to-list(True);
        } else {
            die 'this should never happen';
        }

        for @.predicates -> $predicate {
            # a predicate should basically evaluate to a ResultList of True and False
            # or Number

            my $interim = XML::XPath::Result::ResultList.new;
            for $result.nodes.kv -> $index, $node {
                my $predicate-result = $predicate.evaluate($result, :$index);
                say "predicate-result";
                say $predicate-result;

                if $predicate-result ~~ XML::XPath::Result::Number {
                    $interim.add: $node if $predicate-result.value - 1 == $index;
                } elsif $predicate-result ~~XML::XPath::Result::Boolean {
                    $interim.add: $node if $predicate-result.Bool;
                } else {
                    for $predicate-result.nodes.kv -> $i, $node-result {
                        $interim.add: $result[$i] if $node-result.Bool;
                    }
                }
            }
            $result = $interim;
        }

        if $.next {
            $result = $.next.evaluate($result);
        }
        return $result;
    }
}
