use v6.c;
use XML::XPath::Result::ResultList;
use XML::XPath::Evaluable;
use XML::XPath::Types;

class XML::XPath::NodeTest does XML::XPath::Evaluable {
    has Type $.type = "node";
    has Str $.value;

    method evaluate(XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        if $index.defined {
            return self!evaluate-node($set[$index], $axis);
        } else {
            my XML::XPath::Result::ResultList $result .= new;
            for $set.nodes -> $node {
                $result.add: self!evaluate-node($node, $axis);
            }
            return $result;
        }
    }

    method !evaluate-node(XML::XPath::Result::Node $node, Axis $axis --> XML::XPath::Result) {
        my $xml-node = $node.value;
        my XML::XPath::Result $result;
        given $axis {
            when 'self' {
                $result = self!test-node($xml-node);
            }
            when 'child' {
                $result = XML::XPath::Result::ResultList.new;
                if $xml-node.can('nodes') {
                    for $xml-node.nodes -> $child {
                        $result.add: self!test-node($child);
                    }
                }
            }
            when 'descendant' {
                $result = XML::XPath::Result::ResultList.new;
                self!walk-descendant($xml-node, $result);
            }
            when 'descendant-or-self' {
                $result = XML::XPath::Result::ResultList.new;
                $result.add: self!test-node($xml-node);
                self!walk-descendant($xml-node, $result);
            }
            when 'attribute' {
                $result = XML::XPath::Result::ResultList.new;
                for $xml-node.attribs.kv -> $key, $val {
                    if $.value eq '*' or $.value eq $key {
                        $result.add($val);
                    } else {
                        $result.add();
                    }
                }
                $result = $result.trim: :to-list(True);
            }
            when 'parent' {
                my $parent = $xml-node.parent;
                unless $parent ~~ XML::Document {
                    $result = self!test-node($parent);
                }
            }
            when 'ancestor' {
                $result = XML::XPath::Result::ResultList.new;
                while ($xml-node = $xml-node.parent) {
                    last if $xml-node ~~ XML::Document;
                    $result.add: self!test-node($xml-node);
                }
            }
            when 'ancestor-or-self' {
                $result = XML::XPath::Result::ResultList.new;
                $result.add: self!test-node($xml-node);
                while ($xml-node = $xml-node.parent) {
                    last if $xml-node ~~ XML::Document;
                    $result.add: self!test-node($xml-node);
                }
            }
            when 'following-sibling' {
                my @fs = self!get-following-siblings($xml-node);
                $result = XML::XPath::Result::ResultList.new;
                for @fs {
                    $result.add: self!test-node($_);
                }
            }
            when 'following' {
                my @fs = self!get-following($xml-node);
                $result = XML::XPath::Result::ResultList.new;
                for @fs {
                    $result.add: self!test-node($_);
                    self!walk-descendant($_, $result);
                }
            }
            when 'preceding-sibling' {
                my @fs = self!get-preceding-siblings($xml-node);
                $result = XML::XPath::Result::ResultList.new;
                for @fs {
                    $result.add: self!test-node($_);
                }
            }
            when 'preceding' {
                my @fs = self!get-preceding($xml-node);
                $result = XML::XPath::Result::ResultList.new;
                for @fs {
                    $result.add: self!test-node($_);
                    self!walk-descendant($_, $result);
                }
            }
            default {
                X::NYI.new(feature => "axis $_").throw;
            }
        }
        return $result;
    }

    method !get-preceding(XML::Node $xml-node is copy) {
        my @preceding;
        loop {
            my $parent = $xml-node.parent;
            last if $parent ~~ XML::Document;
            # document order!
            @preceding.prepend: self!get-preceding-siblings($xml-node);;
            $xml-node = $parent;
        }
        @preceding;
    }
    method !get-preceding-siblings(XML::Node $xml-node) {
        my $parent = $xml-node.parent;
        unless $parent ~~ XML::Document {
            my $pos = $parent.index-of($xml-node);
            return $parent.nodes[0 .. $pos-1].reverse;
        }
        return ();
    }

    method !get-following(XML::Node $xml-node is copy) {
        my @following;
        loop {
            my $parent = $xml-node.parent;
            last if $parent ~~ XML::Document;
            # document order!
            @following.append: self!get-following-siblings($xml-node);;
            $xml-node = $parent;
        }
        @following;
    }
    method !get-following-siblings(XML::Node $xml-node) {
        my $parent = $xml-node.parent;
        unless $parent ~~ XML::Document {
            my $pos = $parent.index-of($xml-node);
            return $parent.nodes[$pos+1 .. *];
        }
        return ();
    }

    method !walk-descendant(XML::Node $node, XML::XPath::Result::ResultList $result) {
        return unless $node.can('nodes');
        for $node.nodes -> $child {
            $result.add: self!test-node($child);
            self!walk-descendant($child, $result);
        }
    }

    method !test-node(XML::Node $node --> XML::XPath::Result::Node) {
        my Bool $take = False;
        given $.type {
            when 'node' {
                if $.value ~~ Str:U {
                    $take = True;
                } elsif $.value eq '*' {
                    $take = $node ~~ XML::Element;
                } else {
                    my $name = $.value;
                    if $.value.contains(':') {
                        my @values = $.value.split(/':'/);
                        my $ns = @values[0];

                        # test NS
                        if $node ~~ XML::Element {
                            # TODO how does ns in XML work?
                            X::NYI.new(feature => 'namespaces in nodetests').throw;
                        }
                        $name = @values[1];
                    }
                    if $node ~~ XML::Element {
                        $take = $node.name eq $name;
                    }
                }
            }
            when 'text' {
                $take = $node ~~ XML::Text;
            }
            when 'comment' {
                $take = $node ~~ XML::Commend;
            }
            when 'processsing-instruction ' {
                if $.value {
                    $take = $node.data.starts-with($.value);
                } else {
                    $take = $node ~~ XML::PI;
                }
            }
        }
        return XML::XPath::Result::Node.new( value => $node) if $take;
        return XML::XPath::Result::Node:U;
    }
}
