use v6.c;
use XML::XPath::NodeSet;
use XML::XPath::Evaluable;
use XML::XPath::Testable;

class XML::XPath::Expr does XML::XPath::Evaluable {
    has $.operand is rw;
    has $.operator is rw;
    has $.other-operand is rw;
    has @.predicates;

    method evaluate(XML::XPath::NodeSet $set --> XML::XPath::NodeSet) {
        my $result;
        if ($.operand ~~ XML::XPath::Testable) {
            $result = XML::XPath::NodeSet.new;
            # test on NodeSet instead of Node itself. FIXME
            $.operand.test($set, $result);
        } elsif ($.operand ~~ XML::XPath::Evaluable)
                 and $.operator
                 and ($.other-operand ~~ XML::XPath::Evaluable) {
            # evalute operand
            # then other-operand
            my $other-set = $.other-operand.evalutate($set);
            X::NYI.new(feature => 'evalute of Expr with operator').throw;
            # and use the operator
        } elsif ($.operand ~~ XML::XPath::Evaluable) {
            $result = $.operand.evaluate($set);
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
