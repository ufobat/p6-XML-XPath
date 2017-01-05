use v6.c;

use XML::XPath::Result;
use XML::XPath::Result::ResultList;
use XML::XPath::Types;

class XML::XPath::ExprOperator::Pipe {
    method invoke($expr, XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        my $first-set = $expr.operand.evaluate($set, :$axis, :$index);
        my $other-set = $expr.other-operand.evaluate($set, :$axis, :$index);
        $first-set.add($other-set);
        return $first-set;
    }
}
