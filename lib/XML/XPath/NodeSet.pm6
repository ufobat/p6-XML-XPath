use v6.c;

use XML;

class XML::XPath::NodeSet {
    has XML::Node @.nodes;

    method add(XML::Node $elem) {
        @.nodes.push($elem);
    }

    multi method new(XML::Document $document) {
        my @nodes = ($document.root);
        self.bless(:@nodes);
    }
    multi method new() {
        self.bless();
    }
}
