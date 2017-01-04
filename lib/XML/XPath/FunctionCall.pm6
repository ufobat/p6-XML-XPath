use v6.c;

use XML::XPath::Evaluable;
use XML::XPath::Result::Number;
use XML::XPath::Types;
use XML::XPath::Result::ResultList;

class XML::XPath::FunctionCall does XML::XPath::Evaluable {
    has $.function is required;
    has @.args;

    method evaluate(XML::XPath::Result::ResultList $set, Axis :$axis = 'self', Int :$index) {
        return self!"fn-{ $.function }"($set, $axis, $index);
    }

    method !fn-last(XML::XPath::Result::ResultList $set, Axis $axis, Int $index) {
        die 'functioncall last() requires no parameter' unless @.args.elems == 0;
        return $index.defined
        ?? XML::XPath::Result::Number.new(value => $set.elems)
        !! XML::XPath::Result::Boolean.new(value => $index == $set.elems);
    }

    method !fn-not(XML::XPath::Result::ResultList $set, Axis $axis, Int $index) {
        die 'functioncall not() requires one parameter' unless @.args.elems == 1;
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

    method !fn-count(XML::XPath::Result::ResultList $set, Axis $axis, Int $index) {
        die 'functioncall count() requires one parameter' unless @.args.elems == 1;
        my $expr    = @.args[0];
        my $interim = $expr.evaluate($set, :$axis, :$index);
        my $result  = XML::XPath::Result::Number.new(value => $interim.elems);
        return $result;
    }

    method !fn-name(XML::XPath::Result::ResultList $set, Axis $axis, Int $index) {
        die "name can not have more then one parameter: @.args.elems" if @.args.elems > 1;
        if @.args.elems == 1 {
            my $expr    = @.args[0];
            my $interim = $expr.evaluate($set, :$axis, :$index).trim;;
            if $interim ~~ XML::XPath::Result::ResultList {
                my $result  = XML::XPath::Result::ResultList.new;
                for $interim.nodes -> $node {
                    $result.add: $node.value.name;
                }
                return $result;
            } elsif $interim ~~ XML::XPath::Result::Node {
                XML::XPath::Result::String.new( value => $interim.node.name );
            } else {
                return XML::XPath::Result:U;
            }
        } else {
            # the more common way for name()
            if $index.defined {
                return XML::XPath::Result::String.new( value => $set[$index].value.name );
            } else {
                my $result  = XML::XPath::Result::ResultList.new;
                for $set.nodes -> $node {
                    $result.add: $node.value.name;
                }
                return $result;
            }
        }
    }

    ## normalize-space and string-length
    ## work the same way
    method !help-one-arg-string(XML::XPath::Result::ResultList $set, Axis $axis, Int $index, Sub $converter) {
        my $expr    = @.args[0];
        my $interim = $expr.evaluate($set, :$axis, :$index);
        if $interim ~~ XML::XPath::Result::ResultList {
            my $result  = XML::XPath::Result::ResultList.new;
            for $interim.nodes -> $node {
                $result.add: $converter.($node);
            }
            return $result;
        } else {
            return $converter.($interim);
        }
    }
    method !fn-string-length(XML::XPath::Result::ResultList $set, Axis $axis, Int $index) {
        die 'functioncall normalize-space() reqires one parameter' unless @.args.elems == 1;
        my $converter = sub (XML::XPath::Result $r){
            XML::XPath::Result::Number.new(value => $r.Str.chars)
        };
        self!help-one-arg-string($set, $axis, $index, $converter);
    }
    method !fn-normalize-space(XML::XPath::Result::ResultList $set, Axis $axis, Int $index) {
        die 'functioncall normalize-space() reqires one parameter' unless @.args.elems == 1;
        my $converter = sub (XML::XPath::Result $r){
            XML::XPath::Result::String.new(value => $r.Str.trim)
        };
        self!help-one-arg-string($set, $axis, $index, $converter);
    }

    ## starts-with and contains
    ## work the same way
    method !help-two-arg-second-string(XML::XPath::Result::ResultList $set, Axis $axis, Int $index, Sub $converter) {
        my $interim        = @.args[0].evaluate($set, :$axis, :$index);
        my $string-result  = @.args[1].evaluate($set, :$axis, :$index);
        unless $string-result ~~XML::XPath::Result::String {
            die 'functioncall 2nd expression must evaluate into a String';
        }
        my $string = $string-result.Str;
        if $interim ~~ XML::XPath::Result::ResultList {
            my $result  = XML::XPath::Result::ResultList.new;
            for $interim.nodes -> $node {
                $result.add: $converter.($node, $string);
            }
            return $result;
        } else {
            return XML::XPath::Result::Boolean.new( value => $converter.($interim, $string) );
        }
    }
    method !fn-starts-with(XML::XPath::Result::ResultList $set, Axis $axis, Int $index) {
        die "functioncall starts-with() requires two parameters" unless @.args.elems == 2;
        my $converter = sub (XML::XPath::Result $r, Str $s){ $r.Str.starts-with($s) };
        return self!help-two-arg-second-string($set, $axis, $index, $converter);
    }
    method !fn-contains(XML::XPath::Result::ResultList $set, Axis $axis, Int $index) {
        die "functioncall containts() requires two parameters" unless @.args.elems == 2;
        my $converter = sub (XML::XPath::Result $r, Str $s){ $r.Str.contains($s) };
        return self!help-two-arg-second-string($set, $axis, $index, $converter);
    }
}
