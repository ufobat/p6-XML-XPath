use v6.c;

use XML::XPath::Result;

class XML::XPath::Result::String does XML::XPath::Result {
    has Str $.value;

    method equals(XML::XPath::Result $other) {
        return $.value eq $other.Str();
    }

    method Str {
        $.value;
    }

    method Bool {
        $.value.Bool;
    }

    method Int {
        $.value.Int;
    }

}
