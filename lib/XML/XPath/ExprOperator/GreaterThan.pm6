use v6.c;

use XML::XPath::InfixExprOperatorPerElement;

class XML::XPath::ExprOperator::GreaterThan does XML::XPath::InfixExprOperatorPerElement {

    method check(XML::XPath::Result $a, XML::XPath::Result $b) {
        unless $a.defined and $b.defined {
            return XML::XPath::Result::Bolean.new( value => False );
        }
        return XML::XPath::Result::Boolean.new( value => $a.value > $b.value);
    }
}
