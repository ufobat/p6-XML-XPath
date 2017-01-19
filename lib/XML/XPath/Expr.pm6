use v6.c;
use XML::XPath::Evaluable;
use XML::XPath::Predicates;
use XML::XPath::Types;
use XML::XPath::ExprOperator::Equal;
use XML::XPath::ExprOperator::Mod;
use XML::XPath::ExprOperator::Or;
use XML::XPath::ExprOperator::Pipe;
use XML::XPath::ExprOperator::Plus;
use XML::XPath::ExprOperator::Minus;
use XML::XPath::ExprOperator::Div;
use XML::XPath::ExprOperator::SmallerThan;
use XML::XPath::ExprOperator::GreaterThan;

class XML::XPath::Expr does XML::XPath::Evaluable {
    has $.operand is rw;
    has Operator $.operator is rw;
    has $.other-operand is rw;
    has XML::XPath::Predicates $.predicates is rw = XML::XPath::Predicates.new;

    method evaluate(ResultType $set, Int $index, Int $of) {
        my $result;

        # todo proove of TODO
        #die if $set.elems > 1 && not( $index.defined );

        if ($.operand ~~ XML::XPath::Evaluable)
        and $.operator
        and ($.other-operand ~~ XML::XPath::Evaluable) {

            try {
                my $operator-strategy = ::('XML::XPath::ExprOperator::' ~ $.operator).new;
                $result = $operator-strategy.invoke(self, $set, $index, $of);
                CATCH {
                    say "caught $_";
                }
            }

        } elsif ($.operand ~~ XML::XPath::Evaluable) {
            $result = $.operand.evaluate($set, $index, $of);
        } else {
            $result = [ $.operand ];
        }

        return $.predicates.evaluate-predicates($result);
    }
}

