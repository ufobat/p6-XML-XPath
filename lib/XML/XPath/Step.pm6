use v6.c;
use XML::XPath::Result::ResultList;
use XML::XPath::NodeTest;
use XML::XPath::Evaluable;
use XML::XPath::Types;

class XML::XPath::Step does XML::XPath::Evaluable {
    has Axis $.axis is rw is required;
    has XML::XPath::NodeTest $.test = XML::XPath::NodeTest.new;
    has @.predicates;
    has XML::XPath::Step $.next is rw;
    has Bool $.is-absolute is rw = False;

    method add-next(XML::XPath::Step $step) {
        if $.next {
            $.next.add-next($step);
        } else {
            $.next = $step;
        }
    }

    method evaluate(XML::XPath::Result::ResultList $set, Int :$index) {
        my XML::XPath::Result::ResultList $result .= new;
        my $start-evaluation-list = $.is-absolute
        ?? self!get-resultlist-with-root($set)
        !! $set;

        # this can be removed when predicate invokation works. TODO
        if $index.defined {
            my $elem = $start-evaluation-list[$index];
            $start-evaluation-list = XML::XPath::Result::ResultList.new();
            $start-evaluation-list.add: $elem;
        }
        
        # this can be removed when predicate invokation works. TODO
        #say "step with test axis = $.axis test =  ", $.test.type , " ", $.test.value;
        for $start-evaluation-list.nodes -> $node {
            #say "node -> ", $node.perl;
            my $tmp = $.test.evaluate-node($node, $.axis).trim: :to-list(True);
            #say "adding ", $tmp;
            $result.append( $tmp );
        }

        # todo proove of TODO
        die if $start-evaluation-list.elems > 1;
        
        for @.predicates -> $predicate {
            # a predicate should basically evaluate to a ResultList of True and False
            # or Number

            my $interim = XML::XPath::Result::ResultList.new;
            for $result.nodes.kv -> $index, $node {
                my $predicate-result = $predicate.evaluate($result, :$index);
                say "predicate";
                say $predicate-result.perl;

                if ($predicate-result ~~ XML::XPath::Result::ResultList) and ($predicate-result.elems == 1) {
                    $predicate-result = $predicate-result.trim
                }

                if $predicate-result ~~ Numeric and $predicate-result !~~ Stringy and $predicate-result !~~ Bool {
                    $interim.add: $node if $predicate-result - 1 == $index;
                } elsif $predicate-result ~~ Bool {
                    $interim.add: $node if $predicate-result.Bool;
                } elsif $predicate-result ~~ Str {
                    $interim.add: $node if $predicate-result.Bool;
                } else {
                    for $predicate-result.nodes.kv -> $i, $node-result {
                        $interim.add: $result[$i] if $node-result.Bool;
                    }
                }
            }
            $result = $interim;
        }

        if $.next {
            #say "!! calling next step with ", $result.elems;
            
            my $next-step-result = XML::XPath::Result::ResultList.new;
            for $result.nodes -> $node {
                #say "!! node", $node.perl;
                my $interim = XML::XPath::Result::ResultList.new;
                $interim.add: $node;
                $next-step-result.append: $.next.evaluate($interim);
            }
            $result = $next-step-result;
        }
        return $result;
    }

    method !get-resultlist-with-root(XML::XPath::Result::ResultList $start) {
        die 'can not calculate a root node from an empty list' unless $start.elems > 0;
        my $rs = XML::XPath::Result::ResultList.new;
        for $start.nodes -> $node {
            my $elem = $start[0];
            my $doc = $elem ~~ XML::Document ?? $elem !! $elem.ownerDocument;
            $rs.add: $doc;
        }
        return $rs;
    }
}
