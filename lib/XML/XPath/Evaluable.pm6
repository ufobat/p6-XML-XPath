use v6.c;

use XML::XPath::NodeSet;

role XML::XPath::Evaluable {
    method evaluate(XML::XPath::NodeSet $set, Bool $take) {...}
}
