use v6.c;

use XML::XPath::Evaluable;
use XML::XPath::Types;
use XML::XPath::Result::ResultList;

class XML::XPath::FunctionCall does XML::XPath::Evaluable {
    has $.function is required;
    has @.args;

    method evaluate(XML::XPath::Result::ResultList $set, Int :$index) {
        return self!"fn-{ $.function }"($set, $index);
    }

    method !fn-last(XML::XPath::Result::ResultList $set, Int $index) {
        die 'functioncall last() requires no parameter' unless @.args.elems == 0;
        return $index.defined
        ?? $set.elems
        !! $index == $set.elems;
    }

    method !fn-not(XML::XPath::Result::ResultList $set, Int $index) {
        die 'functioncall not() requires one parameter' unless @.args.elems == 1;
        my $expression = @.args[0];
        my $interim = $expression.evaluate($set, :$index);
        return !$interim.Bool;
    }

    method !fn-position(XML::XPath::Result::ResultList $set, Int $index) {
        die 'functioncall position() requires no parameter' unless @.args.elems == 0;
        return $index;
    }

    method !fn-count(XML::XPath::Result::ResultList $set, Int $index) {
        die 'functioncall count() requires one parameter' unless @.args.elems == 1;
        my $expr    = @.args[0];
        my $interim = $expr.evaluate($set, :$index);
        return $interim.elems;
    }

    method !fn-name(XML::XPath::Result::ResultList $set, Int $index) {
        die "name can not have more then one parameter: @.args.elems" if @.args.elems > 1;
        if @.args.elems == 1 {
            my $expr    = @.args[0];
            my $interim = $expr.evaluate($set, :$index).trim;;
            if $interim ~~ XML::XPath::Result::ResultList {
                my $result  = XML::XPath::Result::ResultList.new;
                for $interim.nodes -> $node {
                    $result.add: $node.name;
                }
                return $result;
            } elsif $interim ~~ XML::Node {
                return $interim.name;
            } else {
                return Nil;
            }
        } else {
            # the more common way for name()
            if $index.defined {
                return $set[$index].name;
            } else {
                my $result  = XML::XPath::Result::ResultList.new;
                for $set.nodes -> $node {
                    $result.add: $node.name;
                }
                return $result;
            }
        }
    }

    ## normalize-space and string-length
    ## work the same way
    method !help-one-arg-string(XML::XPath::Result::ResultList $set, Int $index, Sub $converter) {
        my $expr    = @.args[0];
        my $interim = $expr.evaluate($set, :$index);
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
    method !fn-floor(XML::XPath::Result::ResultList $set, Int $index) {
        die 'functioncall floor() requires no parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.floor
        };
        self!help-one-arg-string($set, $index, $converter);
    }
    method !fn-ceiling(XML::XPath::Result::ResultList $set, Int $index) {
        die 'functioncall floor() requires no parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.ceiling;
        };
        self!help-one-arg-string($set, $index, $converter);
    }
    method !fn-round(XML::XPath::Result::ResultList $set, Int $index) {
        die 'functioncall floor() requires no parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.round;
        };
        self!help-one-arg-string($set, $index, $converter);
    }
    method !fn-string-length(XML::XPath::Result::ResultList $set, Int $index) {
        die 'functioncall normalize-space() reqires one parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.defined ?? $r.Str.chars !! 0;
        };
        self!help-one-arg-string($set, $index, $converter);
    }
    method !fn-normalize-space(XML::XPath::Result::ResultList $set, Int $index) {
        die 'functioncall normalize-space() reqires one parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.Str.trim;
        };
        self!help-one-arg-string($set, $index, $converter);
    }

    ## starts-with and contains
    ## work the same way
    method !help-two-arg-second-string(XML::XPath::Result::ResultList $set, Int $index, Sub $converter) {
        my $interim        = @.args[0].evaluate($set, :$index);
        my $string-result  = @.args[1].evaluate($set, :$index);
        unless $string-result ~~ Str {
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
            return $converter.($interim, $string);
        }
    }
    method !fn-starts-with(XML::XPath::Result::ResultList $set, Int $index) {
        die "functioncall starts-with() requires two parameters" unless @.args.elems == 2;
        my $converter = sub ($r, Str $s){ $r.Str.starts-with($s) };
        return self!help-two-arg-second-string($set, $index, $converter);
    }
    method !fn-contains(XML::XPath::Result::ResultList $set, Int $index) {
        die "functioncall containts() requires two parameters" unless @.args.elems == 2;
        my $converter = sub ($r, Str $s){ $r.Str.contains($s) };
        return self!help-two-arg-second-string($set, $index, $converter);
    }
}
