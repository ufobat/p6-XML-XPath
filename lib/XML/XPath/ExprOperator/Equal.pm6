use v6.c;

use XML::XPath::Result;
use XML::XPath::Result::ResultList;
use XML::XPath::Types;

class XML::XPath::ExprOperator::Equal {
    method invoke($expr, XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        my $first-set = $expr.operand.evaluate($set, :$axis, :$index);
        my $other-set = $expr.other-operand.evaluate($set, :$axis, :$index);
        return self.op-result-helper($first-set, $other-set);
    }

    multi method op-result-helper(XML::XPath::Result:D $one, XML::XPath::Result:D $another) {
        XML::XPath::Result::Boolean.new: value => $one.equals($another);
    }
    multi method op-result-helper(XML::XPath::Result:D $one, XML::XPath::Result:U $another) {
        XML::XPath::Result::Boolean.new: value => False,
    }
    multi method op-result-helper(XML::XPath::Result:U $one, XML::XPath::Result:D $another) {
        XML::XPath::Result::Boolean.new: value => False,
    }
    multi method op-result-helper(XML::XPath::Result:U $one, XML::XPath::Result:U $another) {
        XML::XPath::Result::Boolean.new: value => False,
    }
    multi method op-result-helper(XML::XPath::Result::ResultList $one, XML::XPath::Result $another) {
        self.op-result-helper($another, $one);
    }
    multi method op-result-helper(XML::XPath::Result $one, XML::XPath::Result::ResultList $another) {
        my $result = XML::XPath::Result::ResultList.new;
        for $another.nodes -> $node {
            $result.add: self.op-result-helper($node, $one);
        }
        return $result;
    }
    multi method op-result-helper(XML::XPath::Result::ResultList $one, XML::XPath::Result::ResultList $another) {
        my $maxsize = $one.elems max $another.elems;
        my $result = XML::XPath::Result::ResulList.new;

        for 0..$maxsize -> $index {
            $result.add: self.op-result-helper($one[$index], $another[$index])
        }
        return $result;
    }
}
