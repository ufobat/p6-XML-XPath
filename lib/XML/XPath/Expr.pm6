use v6.c;
use XML::XPath::Result::ResultList;
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

    method evaluate(XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        return self!evaluate($set, $axis, $index);
    }
    method !evaluate($set, Axis $axis, Int $index,) {
        my $result;

        if ($.operand ~~ XML::XPath::Evaluable)
        and $.operator
        and ($.other-operand ~~ XML::XPath::Evaluable) {
            # evalute operand
            # then other-operand
            ## TODO that is wrong
            if %operator-dispatch{$.operator}:exists {
                my $first-set = $.operand.evaluate($set, :$axis, :$index);
                my $other-set = $.other-operand.evaluate($set, :$axis, :$index);

                $result = self."%operator-dispatch{$.operator}"($first-set, $other-set);
           } else {
                X::NYI.new(feature => "Evaluaion of an Expr with $.operator operator").throw;
            }

            # and use the operator
        } elsif ($.operand ~~ XML::XPath::Evaluable) {
            $result = $.operand.evaluate($set, :$axis, :$index);
        } elsif ($.operand ~~ Str) {
            $result = XML::XPath::Result::String.new: value => $.operand;
        } elsif ($.operand ~~ Int) {
            $result = XML::XPath::Result::Number.new: value => $.operand;
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

    # in case signatures dont match ($what is a NodeSet) just loop over it.
    multi method op-equal(XML::XPath::Result:D $one, XML::XPath::Result:D $another) {
        XML::XPath::Result::Boolean.new: value => $one.equals($another);
    }
    multi method op-equal(XML::XPath::Result:D $one, XML::XPath::Result:U $another) {
        XML::XPath::Result::Boolean.new: value => False,
    }
    multi method op-equal(XML::XPath::Result:U $one, XML::XPath::Result:D $another) {
        XML::XPath::Result::Boolean.new: value => False,
    }
    multi method op-equal(XML::XPath::Result:U $one, XML::XPath::Result:U $another) {
        XML::XPath::Result::Boolean.new: value => False,
    }
    multi method op-equal(XML::XPath::Result::ResultList $one, XML::XPath::Result $another) {
        self.op-equal($another, $one);
    }
    multi method op-equal(XML::XPath::Result $one, XML::XPath::Result::ResultList $another) {
        my $result = XML::XPath::Result::ResultList.new;
        for $another.nodes -> $node {
            $result.add: self.op-equal($node, $one);
        }
        return $result;
    }
    multi method op-equal(XML::XPath::Result::ResultList $one, XML::XPath::Result::ResultList $another) {
        my $maxsize = $one.elems max $another.elems;
        my $result = XML::XPath::Result::ResulList.new;

        for 0..$maxsize -> $index {
            $result.add: self.op-equal($one[$index], $another[$index])
        }
        return $result;
    }
}
