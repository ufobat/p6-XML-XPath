use v6.c;
use XML::XPath::NodeSet;

class XML::XPath::Expr {
    has $.operand is rw;
    has $.operator is rw;
    has $.other-operand is rw;
    has @.predicates;

    method evaluate(XML::XPath::NodeSet $set) {
        my $nodeset = $.operand.evaluate($set);
        if @.predicates {
            # TODO apply predicates to nodeset
            X::NYI.new(feature => 'evalute of Expr with predicates').throw;
        }
        if $.operator {
            # operator and $.next belong together
            my $other-set = $.other-operand.evalutate($set);
            # TODO to something smart with $.expression and $rhs-set;
            X::NYI.new(feature => 'evalute of Expr with operator').throw;
        }
        return $nodeset
    }
}
