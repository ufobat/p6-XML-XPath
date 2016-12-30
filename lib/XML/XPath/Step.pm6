use v6.c;
use XML::XPath::NodeSet;
use XML::XPath::NodeTest;
use XML::XPath::Evaluable;

class XML::XPath::Step does XML::XPath::Evaluable {
    # TODO
    subset Axis of Str where {$_ ~~ <child self attribute descendant descendant-or-self namespace>.any};

    has Axis $.axis is rw is required;
    has XML::XPath::NodeTest $.test = XML::XPath::NodeTest.new;
    has @.predicates;
    has XML::XPath::Step $.next is rw;

    method evaluate(XML::XPath::NodeSet $set) {
        my $result = XML::XPath::NodeSet.new;
        if $.axis {
            $.test.test($set, $result, $.axis);
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
}
