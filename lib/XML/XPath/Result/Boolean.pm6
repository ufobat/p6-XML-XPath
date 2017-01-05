use v6.c;

use XML::XPath::Result;

class XML::XPath::Result::Boolean does XML::XPath::Result {
    has Bool $.value;

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
