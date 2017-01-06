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
                $result = self!test-node($xml-node, $xml-node);
            }
            when 'child' {
                $result = XML::XPath::Result::ResultList.new;
                if $xml-node.can('nodes') {
                    for $xml-node.nodes -> $child {
                        $result.add: self!test-node($child, $xml-node);
                    }
                }
            }
            when 'descendant' {
                $result = XML::XPath::Result::ResultList.new;
                self!walk-descendant($xml-node, $xml-node, $result);
            }
            when 'descendant-or-self' {
                $result = XML::XPath::Result::ResultList.new;
                $result.add: self!test-node($xml-node, $xml-node);
                self!walk-descendant($xml-node, $xml-node, $result);
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
                $result = self!test-node($parent, $parent);
            }
            when 'ancestor' {
                $result = XML::XPath::Result::ResultList.new;
                while ($xml-node = $xml-node.parent) {
                    last if $xml-node ~~ XML::Document;
                    $result.add: self!test-node($xml-node, $xml-node);
                }
            }
            when 'ancestor-or-self' {
                $result = XML::XPath::Result::ResultList.new;
                $result.add: self!test-node($xml-node, $xml-node);
                while ($xml-node = $xml-node.parent) {
                    last if $xml-node ~~ XML::Document;
                    $result.add: self!test-node($xml-node, $xml-node);
                }
            }
            default {
                X::NYI.new(feature => "axis $_").throw;
            }
        }
        return $result;
    }

    method !walk-descendant(XML::Node $node, XML::Node $node-from-set, XML::XPath::Result::ResultList $result) {
        return unless $node.can('nodes');
        for $node.nodes -> $child {
            $result.add: self!test-node($child, $node-from-set);
            self!walk-descendant($child, $node-from-set, $result);
        }
    }

    method !test-node(XML::Node $node, XML::Node $node-from-set --> XML::XPath::Result::Node) {
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
