use v6.c;

use XML;

class XML::XPath::NodeSet {
    has @.nodes;

    multi method add(Str $elem) {
        @.nodes.push($elem);
    }

    multi method add(XML::Node $elem) {
        @.nodes.push($elem);
    }

    multi method add(XML::XPath::NodeSet $other) {
        for $other.nodes -> $node {
            self.add: $node;
        }
    }

    method equals(XML::XPath::NodeSet $other) {
        return set(@.nodes) ~~ set($other.nodes);
    }

    method contains($something) {
        return $something ~~ @.nodes.any;
    }

    multi method new(XML::Document $document) {
        my @nodes = ($document.root);
        self.bless(:@nodes);
    }
    multi method new() {
        self.bless();
    }
}
