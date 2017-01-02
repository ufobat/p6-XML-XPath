use v6.c;

use XML;
use XML::XPath::Result::ResultList;
use XML::XPath::Types;

role XML::XPath::Evaluable {
    multi method evaluate(XML::XPath::Result::ResultList $set, Bool $predicate, Axis :$axis = 'self', Int :$index) {...}
    multi method evaluate(XML::XPath::Result::ResultList $set, XML::XPath::Result::Node $node, Bool $predicate, Axis :$axis = 'self', Int :$index) {...}
}
