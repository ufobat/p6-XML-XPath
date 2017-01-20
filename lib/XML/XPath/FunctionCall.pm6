use v6.c;

use XML::XPath::Evaluable;
use XML::XPath::Types;
use XML::XPath::Utils;

class XML::XPath::FunctionCall does XML::XPath::Evaluable {
    has $.function is required;
    has @.args;

    method evaluate(ResultType $set, Int $index, Int $of) {
        return self!"fn-{ $.function }"($set, $index, $of);
    }

    method !fn-lang(ResultType $set, Int $index, Int $of) {
        die 'functioncall lang() requires one parameter' unless @.args.elems == 1;
        my $expression = @.args[0];
        my $interim    = $expression.evaluate($set, $index, $of);
        my $string     = unwrap($interim);
        my $xml-node   = $set;
        while $xml-node ~~ XML::Element {
            for $xml-node.attribs.kv -> $key, $val {
                if $key eq 'xml:lang' {
                    return [ $val.fc eq $string.fc ];
                }
            }
            $xml-node = $xml-node.parent;
        }
        return [ False ];
    }

    method !fn-last(ResultType $set, Int $index, Int $of) {
        die 'functioncall last() requires no parameter' unless @.args.elems == 0;
        return [ $of ];
    }

    method !fn-not(ResultType $set, Int $index, Int $of) {
        die 'functioncall not() requires one parameter' unless @.args.elems == 1;
        my $expression = @.args[0];
        my $interim = $expression.evaluate($set, $index, $of);
        return [ !$interim.Bool ];
    }

    method !fn-position(ResultType $set, Int $index, Int $of) {
        die 'functioncall position() requires no parameter' unless @.args.elems == 0;
        return [ $index ];
    }

    method !fn-count(ResultType $set, Int $index, Int $of) {
        die 'functioncall count() requires one parameter' unless @.args.elems == 1;
        my $expr    = @.args[0];
        my $interim = $expr.evaluate($set, $index, $of);
        return [ $interim.elems ];
    }

    method !fn-name(ResultType $set, Int $index, Int $of) {
        die "name can not have more then one parameter: @.args.elems" if @.args.elems > 1;
        my $converter = sub ($r) {
            $r.name;
        }
        if @.args.elems == 1 {
            self!help-one-arg-string($set, $index, $of, $converter);
        } else {
            # the more common way for name()
            return [ $converter.($set) ];
        }
    }

    method !fn-namespace-uri(ResultType $set, Int $index, Int $of) {
        die "namespace-uri can not have more then one parameter: @.args.elems" if @.args.elems > 1;
        my $converter = sub ($r) {
            my ($uri, $node-name) = namespace-infos($r);
            return $uri;
        }
        if @.args.elems == 1 {
            self!help-one-arg-string($set, $index, $of, $converter);
        } else {
            # the more common way for name()
            return [ $converter.($set) ];
        }
    }

    ## normalize-space and string-length
    ## work the same way
    method !help-one-arg-string(ResultType $set, Int $index, Int $of, Sub $converter) {
        my $expr    = @.args[0];
        my $interim = $expr.evaluate($set, $index, $of);
        if $interim ~~ Array {
            my $result = [];
            for $interim.values -> $node {
                $result.push: $converter.($node);
            }
            return $result;
        }
    }
    method !fn-floor(ResultType $set, Int $index, Int $of) {
        die 'functioncall floor() requires no parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.floor
        };
        self!help-one-arg-string($set, $index, $of, $converter);
    }
    method !fn-ceiling(ResultType $set, Int $index, Int $of) {
        die 'functioncall floor() requires no parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.ceiling;
        };
        self!help-one-arg-string($set, $index, $of, $converter);
    }
    method !fn-round(ResultType $set, Int $index, Int $of) {
        die 'functioncall floor() requires no parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.round;
        };
        self!help-one-arg-string($set, $index, $of, $converter);
    }
    method !fn-string-length(ResultType $set, Int $index, Int $of) {
        die 'functioncall normalize-space() reqires one parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.defined ?? $r.Str.chars !! 0;
        };
        self!help-one-arg-string($set, $index, $of, $converter);
    }
    method !fn-normalize-space(ResultType $set, Int $index, Int $of) {
        die 'functioncall normalize-space() reqires one parameter' unless @.args.elems == 1;
        my $converter = sub ($r){
            $r.Str.trim;
        };
        self!help-one-arg-string($set, $index, $of, $converter);
    }

    ## starts-with and contains
    ## work the same way
    method !help-two-arg-second-string(ResultType $set, Int $index, Int $of, Sub $converter) {
        my $interim        = @.args[0].evaluate($set, $index, $of);
        my $string-result  = @.args[1].evaluate($set, $index, $of);
        my $string = unwrap($string-result);
        unless $string ~~ Str {
            die 'functioncall 2nd expression must evaluate into a String';
        }
        if $interim ~~ Array {
            my $result  = [];
            for $interim.values -> $node {
                $result.push: $converter.($node, $string);
            }
            return $result;
        } else {
            return [ $converter.($interim, $string) ];
        }
    }
    method !fn-starts-with(ResultType $set, Int $index, Int $of) {
        die "functioncall starts-with() requires two parameters" unless @.args.elems == 2;
        my $converter = sub ($r, Str $s){ $r.Str.starts-with($s) };
        return self!help-two-arg-second-string($set, $index, $of, $converter);
    }
    method !fn-contains(ResultType $set, Int $index, Int $of) {
        die "functioncall containts() requires two parameters" unless @.args.elems == 2;
        my $converter = sub ($r, Str $s){ $r.Str.contains($s) };
        return self!help-two-arg-second-string($set, $index, $of, $converter);
    }
}
