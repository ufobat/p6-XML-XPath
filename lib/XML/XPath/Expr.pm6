use v6.c;
use XML::XPath::NodeSet;

class XML::XPath::Expr {
    has $.operand is rw;
    has $.operator is rw;
    has $.other-operand is rw;

    method evaluate(XML::XPath::NodeSet $set) {
        if $.operator {
            # operator and $.next belong together
            my $other-set = $.other-operand.evalutate($set);
            # TODO to something smart with $.expression and $rhs-set;
            X::NYI.new(feature => 'evalute of Expr with operator').throw;
        } else {
            return $.operand.evaluate($set);
        }
    }
}
