use v6.c;

use XML;
use XML::XPath::Result;
use XML::XPath::Result::Boolean;
use XML::XPath::Result::Node;
use XML::XPath::Result::Number;
use XML::XPath::Result::String;

class XML::XPath::Result::ResultList does XML::XPath::Result {
    has XML::XPath::Result @.nodes;

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
        for $other.nodes -> $node {
            self.add: $node;
        }
    }
    multi method add(XML::Document $document) {
        my @nodes = ($document.root);
        for @nodes -> $node {
            self.add: $node
        }
    }

    method equals(XML::XPath::Result $other) {
        return @.nodes ~~ $other.ResultList;
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
}
