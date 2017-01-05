use v6.c;

use XML::XPath::Result;
use XML::XPath::Result::ResultList;
use XML::XPath::Types;

role XML::XPath::InfixExprOperatorPerElement {
    method check(XML::XPath::Result $a, XML::XPath::Result $b) { ...}

    method invoke($expr, XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        my $first-set = $expr.operand.evaluate($set, :$axis, :$index);
        my $other-set = $expr.other-operand.evaluate($set, :$axis, :$index);
        return self.op-result-helper($first-set, $other-set);
    }

    multi method op-result-helper(XML::XPath::Result $one, XML::XPath::Result $another) {
        self.check($one, $another);
    }

    multi method op-result-helper(XML::XPath::Result::ResultList $one, XML::XPath::Result $another) {
        my $result = XML::XPath::Result::ResultList.new;
        for $one.nodes -> $node {
            $result.add: self.check($node, $another);
        }
        return $result;
    }

    multi method op-result-helper(XML::XPath::Result $one, XML::XPath::Result::ResultList $another) {
        my $result = XML::XPath::Result::ResultList.new;
        for $another.nodes -> $node {
            #            $result.add: self.op-result-helper($node, $one);
            $result.add: self.check($one, $node);
        }
        return $result;
    }

    multi method op-result-helper(XML::XPath::Result::ResultList $one, XML::XPath::Result::ResultList $another) {
        my $maxsize = $one.elems max $another.elems;
        my $result = XML::XPath::Result::ResulList.new;
        for 0..$maxsize -> $index {
            #$result.add: self.op-result-helper($one[$index], $another[$index]);
            $result.add: XML::XPath::Result::Boolean.new: value => $one[$index].equals($another[$index]);
        }
        return $result;
    }
}
