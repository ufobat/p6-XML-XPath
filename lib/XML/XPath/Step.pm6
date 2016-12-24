use v6.c;
use XML::XPath::Expr;

class XML::XPath::Step is XML::XPath::Expr {
    # TODO
    #subset Axis of Str where {$_ ~~ any<>};
    #subset Test of Str where {$_ ~~ any<>};
    has Str $.axis;
    has Str $.test;
    has Str $.literal;
}
