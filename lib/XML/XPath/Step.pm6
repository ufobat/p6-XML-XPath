use v6.c;
use XML::XPath::NodeTest;
use XML::XPath::Evaluable;
use XML::XPath::Types;
use XML::XPath::Utils;

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

    method evaluate(ResultType $set, Int $index, Int $of) {
        my $start-evaluation = $.is-absolute
        ?? self!get-resultlist-with-root($set)
        !! $set;

        my $result = $.test.evaluate-node($start-evaluation, $.axis);

        for @.predicates -> $predicate {
            # a predicate should basically evaluate to a ResultList of True and False
            # or Number

            my $interim = [];
            for $result.kv -> $index, $node {
                say "\npredicate $index";
                my $predicate-result = $predicate.evaluate($node, $index, $result.elems);
                #say $node.perl;
                say $predicate-result.perl;

                $predicate-result = unwrap($predicate-result);

                if $predicate-result ~~ Numeric and $predicate-result !~~ Stringy and $predicate-result !~~ Bool {
                    $interim.push: $node if $predicate-result - 1 == $index;
                } elsif $predicate-result ~~ Bool {
                    $interim.push: $node if $predicate-result.Bool;
                } elsif $predicate-result ~~ Str {
                    $interim.push: $node if $predicate-result.Bool;
                } else {
                    for $predicate-result.kv -> $i, $node-result {
                        $interim.push: $result[$i] if $node-result.Bool;
                    }
                }
            }
            $result = $interim;
        }

        if $.next {
            my $next-step-result = [];
            for $result.kv -> $index, $node {
                $next-step-result.append: $.next.evaluate($node, $index, $result.elems).flat;
            }
            $result = $next-step-result;
        }
        return $result;
    }

    method !get-resultlist-with-root($elem) {
        return $elem ~~ XML::Document ?? $elem !! $elem.ownerDocument;
    }
}
