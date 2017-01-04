use v6.c;

use XML::XPath::Evaluable;
use XML::XPath::Result::Number;
use XML::XPath::Types;
use XML::XPath::Result::ResultList;

class XML::XPath::FunctionCall does XML::XPath::Evaluable {
    has $.function is required;
    has @.args;

    method evaluate(XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        my $result-of-function;
        given $.function {
            when 'last' {
                return $index.defined
                ?? XML::XPath::Result::Number.new(value => $set.elems)
                !! XML::XPath::Result::Boolean.new(value => $index == $set.elems);
            }
            when 'not' {
                die 'not can use have one parameter' unless @.args.elems == 1;
                my $expression = @.args[0];
                my $interim = $expression.evaluate($set, :$axis, :$index);
                if $interim ~~ XML::XPath::Result::ResultList and $interim.elems > 0 {
                    my $result = XML::XPath::Result::ResultList.new;
                    for $interim.nodes -> $node {
                        $result.add: !$node.Bool;
                    }
                    return $result;
                } else {
                    return XML::XPath::Result::Boolean.new(value => !$interim.Bool);
                }
            }
            when 'normalize-space' {
                die 'not can use have one parameter' unless @.args.elems == 1;
                my $expr    = @.args[0];
                my $interim = $expr.evaluate($set, :$axis, :$index);
                if $interim ~~ XML::XPath::Result::ResultList {
                    my $result  = XML::XPath::Result::ResultList.new;
                    for $interim.nodes -> $node {
                        $result.add: $node.Str.trim;
                    }
                    return $result;
                } else {
                    return XML::XPath::Result::String.new( value => $interim.Str.trim );
                }
            }
            when 'count' {
                die 'not can use have one parameter' unless @.args.elems == 1;
                my $expr    = @.args[0];
                my $interim = $expr.evaluate($set, :$axis, :$index);
                my $result  = XML::XPath::Result::Number.new(value => $interim.elems);
                return $result;
            }
            default {
                X::NYI.new(feature => "functioncall $.function").throw;
            }
        }
    }
}
