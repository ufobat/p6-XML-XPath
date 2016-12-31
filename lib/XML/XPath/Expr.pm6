use v6.c;
use XML::XPath::NodeSet;
use XML::XPath::Evaluable;
use XML::XPath::Types;

class XML::XPath::Expr does XML::XPath::Evaluable {
    has $.operand is rw;
    has $.operator is rw;
    has $.other-operand is rw;
    has @.predicates;

    method evaluate(XML::XPath::NodeSet $set, Bool $predicate, Axis $axis = 'self') {
        my XML::XPath::NodeSet $result;

        if ($.operand ~~ XML::XPath::Evaluable)
        and $.operator
        and ($.other-operand ~~ XML::XPath::Evaluable) {
            # evalute operand
            # then other-operand
            my $other-set = $.other-operand.evalutate($set);
            X::NYI.new(feature => 'evalute of Expr with operator').throw;
            # and use the operator
        } elsif ($.operand ~~ XML::XPath::Evaluable) {
            $result = $.operand.evaluate($set, $predicate, $axis);
        } else {
            # thils should never happen!
            die 'WHAT - this should never happen';
        }

        if @.predicates {
            # TODO apply predicates to nodeset
            X::NYI.new(feature => 'evalute of Expr with predicates').throw;
        }
        return $result;
    }
}
