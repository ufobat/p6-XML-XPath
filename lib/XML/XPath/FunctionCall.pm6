use v6.c;

use XML::XPath::Testable;
use XML::XPath::Number;

class XML::XPath::FunctionCall does XML::XPath::Testable {
    subset Function of Str where {$_ ~~ <last position count id local-name namespace-uri name concat starts-with contain substring-before substring-after substring string-length normalize-space translate boolean not true false lang number sum floor ceiling round>.any};
    has $.function is required;
    has @.args;

    method test(XML::XPath::NodeSet $set, XML::XPath::NodeSet $result, Str $axis = 'self') {
        my $result-of-function;
        given $.function {
            when 'last' {
                $result-of-function = XML::XPath::Number.new(value => $set.nodes.elems);
            }
            default {
                X::NYI.new(feature => 'functioncall $.function').throw;
            }
        }

        $result-of-function.test($set, $result, $axis);
    }
}
