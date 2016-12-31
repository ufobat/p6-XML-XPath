use v6.c;

use XML::XPath::Evaluable;
use XML::XPath::Number;
use XML::XPath::Types;

class XML::XPath::FunctionCall does XML::XPath::Evaluable {
    has $.function is required;
    has @.args;

    method evaluate(XML::XPath::NodeSet $set, Bool $keep, Axis $axis = 'self') {
        my $result-of-function;
        given $.function {
            when 'last' {
                $result-of-function = XML::XPath::Number.new(value => $set.nodes.elems);
            }
            default {
                X::NYI.new(feature => "functioncall $.function").throw;
            }
        }

        return $result-of-function.evaluate($set, $keep, $axis);
    }
}
