use v6.c;

use XML;
use XML::XPath::Result::ResultList;
use XML::XPath::Types;

role XML::XPath::Evaluable {
    method evaluate(XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {...}
}
