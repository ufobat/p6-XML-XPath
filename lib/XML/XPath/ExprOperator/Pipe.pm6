use v6.c;

use XML::XPath::Result;
use XML::XPath::Result::ResultList;
use XML::XPath::Types;

class XML::XPath::ExprOperator::Pipe {
    method invoke($expr, XML::XPath::Result::ResultList $set, Int :$index) {
        my $first-set = $expr.operand.evaluate($set, :$index);
        my $other-set = $expr.other-operand.evaluate($set, :$index);
        $first-set.append($other-set);
        return $first-set;
    }
}
