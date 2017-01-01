use v6.c;
use XML::XPath::NodeSet;
use XML::XPath::Evaluable;
use XML::XPath::Types;

class XML::XPath::Expr does XML::XPath::Evaluable {
    has $.operand is rw;
    has $.operator is rw;
    has $.other-operand is rw;
    has @.predicates;
    my %operator-dispatch = (
        '=' => 'op-equal',
    );

    multi method evaluate(XML::XPath::NodeSet $set, XML::Node $node, Bool $predicate, Axis :$axis = 'self', Int :$index) {
        return self!evaluate($node, $predicate, $axis, $index, :$set);
    }
    multi method evaluate(XML::XPath::NodeSet $set,                  Bool $predicate, Axis :$axis = 'self', Int :$index) {
        return self!evaluate($set, $predicate, $axis, $index);
    }
    method !evaluate($what, Bool $predicate, Axis $axis, Int $index, :$set) {
        my $result;

        if ($.operand ~~ XML::XPath::Evaluable)
        and $.operator
        and ($.other-operand ~~ XML::XPath::Evaluable) {
            # evalute operand
            # then other-operand
            ## TODO that is wrong
            if %operator-dispatch{$.operator}:exists {
                $result = self!"%operator-dispatch{$.operator}"($what, $predicate, $axis, $index, $set);
           } else {
                X::NYI.new(feature => "Evaluaion of an Expr with $.operator operator").throw;
            }

            # and use the operator
        } elsif ($.operand ~~ XML::XPath::Evaluable) {
            $result = $set
            ?? $.operand.evaluate($set, $what, $predicate, :$axis, :$index)
            !! $.operand.evaluate($what, $predicate, :$axis, :$index);
        } elsif ($.operand ~~ Str|Num) {
            $result = XML::XPath::NodeSet.new;
            $result.add: $.operand;
        } else {
            # thils should never happen!
            say self.perl;
            die 'WHAT - this should never happen';
        }

        if @.predicates {
            # TODO apply predicates to nodeset
            X::NYI.new(feature => 'evalute of Expr with predicates').throw;
        }
        return $result;
    }

    # in case signatures dont match ($what is a NodeSet) just loop over it.
    method !op-equal(XML::Node $what, Bool $predicate, Axis $axis, Int $index, XML::XPath::NodeSet $set) {
        my $result = XML::XPath::NodeSet.new;

        my $first-set = $.operand.evaluate($set, $what, False, :$axis, :$index);
        my $other-set = $.other-operand.evaluate($set, $what, False, :$axis, :$index);

        $result.add: $what if $first-set.equals($other-set);
        return $result;
    }
}
