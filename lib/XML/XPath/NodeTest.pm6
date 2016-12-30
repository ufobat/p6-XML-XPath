use v6.c;
use XML::XPath::NodeSet;
use XML::XPath::Testable;

class XML::XPath::NodeTest does XML::XPath::Testable {
    subset Type of Str where { $_ ~~ <comment text node processing-instruction>.any}
    has Type $.type = "node";
    has Str $.value;

    method test(XML::XPath::NodeSet $set, XML::XPath::NodeSet $result, Str $axis = 'self') {
        for $set.nodes -> $node {
            given $axis {
                when 'self' {
                    self!test-node($node, $result);
                }
                when 'child' {
                    return unless $node.can('nodes');
                    for $node.nodes -> $child {
                        self!test-node($child, $result);
                    }
                }
                when 'descendant' {
                    self!walk-descendant($node, $result);
                }
                when 'descendant-or-self' {
                    self!test-node($node, $result);
                    self!walk-descendant($node, $result);
                }
                when 'attribute' {
                    for $node.attribs.kv -> $key, $val {
                        $result.add($val) if $.value eq '*' or $.value eq $key;
                    }
                }
                default {
                    X::NYI.new(feature => "axis $_").throw;
                }
            }
        }
    }

    method !walk-descendant(XML::Node $node, XML::XPath::NodeSet $result) {
        return unless $node.can('nodes');
        for $node.nodes -> $child {
            self!test-node($child, $result);
            self!walk-descendant($child, $result);
        }
    }


    method !test-node(XML::Node $node, XML::XPath::NodeSet $result) {
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

        $result.add($node) if $take;
    }
}
