use v6.c;

use XML;

class XML::XPath::Result::ResultList {
    has @.nodes handles <AT-POS EXISTS-POS elems>;

    multi method add(Str $value) {
        @.nodes.push: $value;
    }
    multi method add(Numeric $value) {
        @.nodes.push: $value;
    }
    multi method add(Bool $value) {
        @.nodes.push: $value;
    }
    multi method add(XML::Node $value) {
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

    method trim(Bool :$to-list) {
        my @trimmed = @.nodes.grep(*.defined);
        if not $to-list and @trimmed.elems == 1 {
            return @trimmed[0];
        }elsif not $to-list and @trimmed.elems == 0 {
            return Nil;
        } else {
            return self.new(nodes => @trimmed);
        }
    }
}
