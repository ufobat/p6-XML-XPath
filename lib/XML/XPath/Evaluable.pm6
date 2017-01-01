use v6.c;

use XML;
use XML::XPath::NodeSet;
use XML::XPath::Types;

role XML::XPath::Evaluable {
    multi method evaluate(XML::XPath::NodeSet $set, Bool $predicate, Axis :$axis = 'self', Int :$index) {...}
    multi method evaluate(XML::XPath::NodeSet $set, XML::Node $node, Bool $predicate, Axis :$axis = 'self', Int :$index) {...}
}
