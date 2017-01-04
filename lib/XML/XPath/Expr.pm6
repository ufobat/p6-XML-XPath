use v6.c;
use XML::XPath::Result::ResultList;
use XML::XPath::Evaluable;
use XML::XPath::Types;
use XML::XPath::ExprOperator::Equal;

class XML::XPath::Expr does XML::XPath::Evaluable {
    has $.operand is rw;
    has Operator $.operator is rw;
    has $.other-operand is rw;
    has @.predicates;

    method evaluate(XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        return self!evaluate($set, $axis, $index);
    }
    method !evaluate($set, Axis $axis, Int $index,) {
        my $result;

        if ($.operand ~~ XML::XPath::Evaluable)
        and $.operator
        and ($.other-operand ~~ XML::XPath::Evaluable) {

            my $operator-strategy = ::('XML::XPath::ExprOperator::' ~ $.operator.tc).new;
            $result = $operator-strategy.invoke(self, $set, :$axis, :$index);

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
}

