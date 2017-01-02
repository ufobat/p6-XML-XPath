use v6.c;
use XML::XPath::Result::ResultList;
use XML::XPath::Evaluable;
use XML::XPath::Types;

class XML::XPath::NodeTest does XML::XPath::Evaluable {
    has Type $.type = "node";
    has Str $.value;

    multi method evaluate(XML::XPath::Result::ResultList $set, XML::XPath::Result::Node $node, Bool $predicate, Axis :$axis = 'self', Int :$index) {
        my XML::XPath::Result::ResultList $result .= new;
        my $xml-node = $node.value;
        given $axis {
            when 'self' {
                self!test-node($xml-node, $xml-node, $result, $predicate);
            }
            when 'child' {
                return $result unless $xml-node.can('nodes');
                for $xml-node.nodes -> $child {
                    self!test-node($child, $xml-node, $result, $predicate);
                }
            }
            when 'descendant' {
                self!walk-descendant($xml-node, $xml-node, $result, $predicate);
            }
            when 'descendant-or-self' {
                self!test-node($xml-node, $xml-node, $result, $predicate);
                self!walk-descendant($xml-node, $xml-node, $result, $predicate);
            }
            when 'attribute' {
                for $xml-node.attribs.kv -> $key, $val {
                    if $.value eq '*' or $.value eq $key {
                        $result.add( $predicate ?? $node !! $val);
                    }
                }
            }
            default {
                X::NYI.new(feature => "axis $_").throw;
            }
        }
        return $result;
    }
    multi method evaluate(XML::XPath::Result::ResultList $set, Bool $predicate, Axis :$axis = 'self', Int :$index) {
        my XML::XPath::Result::ResultList $result .= new;
        for $set.nodes.kv -> $index, $node {
            my $tmp = self.evaluate($set, $node, $predicate, :$axis, :$index);
            $result.add: $tmp;
        }
        return $result;
    }

    method !walk-descendant(XML::Node $node, XML::Node $node-from-set, XML::XPath::Result::ResultList $result, Bool $predicate) {
        return unless $node.can('nodes');
        for $node.nodes -> $child {
            self!test-node($child, $node-from-set, $result, $predicate);
            self!walk-descendant($child, $node-from-set, $result, $predicate);
        }
    }

    method !test-node(XML::Node $node, XML::Node $node-from-set, XML::XPath::Result::ResultList $result, Bool $predicate) {
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
        if $take {
            $result.add( $predicate ?? $node-from-set !! $node );
        }
    }
}
