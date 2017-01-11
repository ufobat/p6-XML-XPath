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
    has Bool $.is-absolute is rw = False;

    method add-next(XML::XPath::Step $step) {
        if $.next {
            $.next.add-next($step);
        } else {
            $.next = $step;
        }
    }

    method evaluate(XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        my XML::XPath::Result $result;
        if $.axis {
            my $start-evaluation-list = $.is-absolute
            ?? self!get-resultlist-with-root($set)
            !! $set;
            $result = $.test.evaluate($start-evaluation-list, :$.axis, :$index).trim: :to-list(True);
        } else {
            die 'this should never happen';
        }

        for @.predicates -> $predicate {
            # a predicate should basically evaluate to a ResultList of True and False
            # or Number

            my $interim = XML::XPath::Result::ResultList.new;
            for $result.nodes.kv -> $index, $node {
                my $predicate-result = $predicate.evaluate($result, :$index);
                say "predicate";
                say $predicate-result.perl;

                if ($predicate-result ~~ XML::XPath::Result::ResultList) and ($predicate-result.elems == 1) {
                    $predicate-result = $predicate-result.trim
                }

                if $predicate-result ~~ XML::XPath::Result::Number {
                    $interim.add: $node if $predicate-result.value - 1 == $index;
                } elsif $predicate-result ~~XML::XPath::Result::Boolean {
                    $interim.add: $node if $predicate-result.Bool;
                } elsif $predicate-result ~~XML::XPath::Result::String {
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

    method !get-resultlist-with-root(XML::XPath::Result::ResultList $start) {
        die 'can not calculate a root node from an empty list' unless $start.elems > 0;
        my $rs = XML::XPath::Result::ResultList.new;
        for $start.nodes -> $node {
            my $elem = $start[0].value;
            my $doc = $elem ~~ XML::Document ?? $elem !! $elem.ownerDocument;
            $rs.add: $doc;
        }
        return $rs;
    }
}
