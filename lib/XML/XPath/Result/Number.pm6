use v6.c;

use XML::XPath::Result;

class XML::XPath::Result::Number does XML::XPath::Result {
    has Int $.value;

    method Str {
        $.value.Str;
    }

    method Bool {
        $.value.Bool;
    }

    method Int {
        $.value;
    }

}
