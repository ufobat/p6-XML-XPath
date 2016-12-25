use v6.c;
use XML::XPath::NodeSet;

class XML::XPath::Expr {
    has $.expression is rw;
    has $.operator is rw;
    has $.next is rw;
    has @.predicates;

    method evaluate(XML::XPath::NodeSet $set) {
        if $.operator {
            # operator and $.next belong together
            my $rhs-set = $.next.evalutate($set);
            # TODO to something smart with $.expression and $rhs-set;
            X::NYI.new(feature => 'evalute of Expr with operator').throw;
        } else {
            return $.expression.evaluate($set);
        }
    }
}
