use v6.c;

use XML::XPath::Result;
use XML;

class XML::XPath::Result::Node does XML::XPath::Result {
    has XML::Node $.value;

    method equals(XML::XPath::Result $other) {
        return $other ~~ XML::XPath::Result::Node and $.value eq $other.value;
    }

    method Str {
        $.value.Str;
    }

    method Bool {
        $.value.Bool;
    }

    method Int {
        $.value.Int;
    }

}
