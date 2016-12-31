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

    method evaluate(XML::XPath::NodeSet $set, Bool $predicate, Axis $axis = 'self') {
        my $result;
        if $.axis {
            $result = $.test.evaluate($set, $predicate, $.axis);
        } else {
            die 'this should never happen';
        }

        for @.predicates {
            $result = $_.evaluate($result, True);
        }

        if $.next {
            $result = $.next.evaluate($result, $predicate);
        }
        return $result;
    }
}
