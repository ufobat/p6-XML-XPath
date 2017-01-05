use v6.c;

use XML::XPath::Result;

class XML::XPath::Result::String does XML::XPath::Result {
    has Str $.value;

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
