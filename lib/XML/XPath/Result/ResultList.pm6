use v6.c;

use XML;
use XML::XPath::Result;
use XML::XPath::Result::Boolean;
use XML::XPath::Result::Node;
use XML::XPath::Result::Number;
use XML::XPath::Result::String;

class XML::XPath::Result::ResultList does XML::XPath::Result {
    has XML::XPath::Result @.nodes handles <AT-POS EXISTS-POS elems>;

    multi method add(Str $value) {
        self.add: XML::XPath::Result::String.new(:$value);
    }
    multi method add(Int $value) {
        self.add: XML::XPath::Result::Number.new(:$value);
    }
    multi method add(Bool $value) {
        self.add: XML::XPath::Result::Boolean.new(:$value);
    }
    multi method add(XML::Node $value) {
        self.add: XML::XPath::Result::Node.new(:$value);
    }
    multi method add(XML::XPath::Result::String $value) {
        @.nodes.push: $value;
    }
    multi method add(XML::XPath::Result::Number $value) {
        @.nodes.push: $value;
    }
    multi method add(XML::XPath::Result::Node $value) {
        @.nodes.push: $value;
    }
    multi method add(XML::XPath::Result::Boolean $value) {
        @.nodes.push: $value;
    }
    multi method add(XML::XPath::Result::ResultList $other) {
        die "append"; # because of refactoring
        for $other.nodes -> $node {
            @.nodes.push: $node;
        }
    }
    multi method append(XML::XPath::Result::ResultList $other) {
        for $other.nodes -> $node {
            @.nodes.push: $node;
        }
    }

    method Str {
        @.nodes.Str;
    }

    method Bool {
        @.nodes.Bool;
    }

    method Int {
        @.nodes.Int;
    }

    method contains($something) {
        return $something ~~ @.nodes.any;
    }

    method trim(Bool :$to-list --> XML::XPath::Result) {
        my @trimmed = @.nodes.grep(*.defined);
        if not $to-list and @trimmed.elems == 1 {
            return @trimmed[0];
        }elsif not $to-list and @trimmed.elems == 0 {
            return XML::XPath::Result:U;
        } else {
            return self.new(nodes => @trimmed);
        }
    }
}
