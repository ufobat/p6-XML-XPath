use v6.c;

use XML::XPath::InfixExprOperatorPerElement;

class XML::XPath::ExprOperator::Div does XML::XPath::InfixExprOperatorPerElement {

    method check(XML::XPath::Result $a, XML::XPath::Result $b) {
        unless $a.defined and $b.defined {
            return XML::XPath::Result::Bolean.new( value => False );
        }
        my $val_a = $a.value ~~ XML::Node ?? self!node-to-value($a.value) !! $a.value;
        my $val_b = $b.value ~~ XML::Node ?? self!node-to-value($b.value) !! $b.value;
        my $value = $val_a / $val_b;
        return XML::XPath::Result::Number.new( :$value );
    }

    method !node-to-value(XML::Node $node) {
        if $node ~~ XML::Element {
            my $txt = $node.contents.join: '';
            return $txt;
        } else {
            X::NYI.new(feature => 'can not handle non XML::Element nodes').throw;
        }
    }
}
