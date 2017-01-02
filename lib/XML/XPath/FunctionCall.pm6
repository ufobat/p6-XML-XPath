use v6.c;

use XML::XPath::Evaluable;
use XML::XPath::Result::Number;
use XML::XPath::Types;
use XML::XPath::Result::ResultList;

class XML::XPath::FunctionCall does XML::XPath::Evaluable {
    has $.function is required;
    has @.args;

    multi method evaluate(XML::XPath::Result::ResultList $set, XML::XPath::Result::Node $node, Bool $predicate, Axis :$axis = 'self', Int :$index) {
        my $result-of-function;
        given $.function {
            when 'last' {
                $result-of-function = XML::XPath::Result::Number.new(value => $set.nodes.elems);
                return $result-of-function;
            }
            when 'not' {
                die 'not can use have one parameter' unless @.args.elems == 1;
                my $expression = @.args[0];
                my $interim = $expression.evaluate($set, $predicate, :$axis);
                if $interim ~~ XML::XPath::Result::ResultList {
                    my $result = XML::XPath::Result::ResultList.new;
                    $result.add($node) unless $interim.contains($node);
                    return $result;
                } else {
                    X::NYI.new(feature => "funcationcal not for { $interim.WHAT }").throw;
                }
            }
            when 'normalize-space' {
                die 'not can use have one parameter' unless @.args.elems == 1;
                my $expr    = @.args[0];
                my $interim = $expr.evaluate($set, $node, $predicate, :$axis, :$index);
                my $result  = XML::XPath::Result::ResultList.new;
                for $interim.nodes -> $node {
                    $result.add: $node.Str.trim;
                }
                return $result;
            }
            when 'count' {
                die 'not can use have one parameter' unless @.args.elems == 1;
                my $expr    = @.args[0];
                my $interim = $expr.evaluate($set, $node, $predicate, :$axis, :$index);
                my $result  = XML::XPath::Result::ResultList.new;
                $result.add: $interim.nodes.elems;
                return $result
            }
            default {
                X::NYI.new(feature => "functioncall $.function").throw;
            }
        }

    }
    multi method evaluate(XML::XPath::Result::ResultList $set, Bool $predicate, Axis :$axis = 'self', Int :$index) {
        for $set.nodes.kv -> $i, $node {
            self.evaluate($set, $node, $predicate, :$axis, index => $i);
        }
    }
}
